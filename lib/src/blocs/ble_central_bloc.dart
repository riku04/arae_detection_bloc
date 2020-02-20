import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_map_app/src/models/area.dart';
import 'package:flutter_map_app/src/models/user_settings.dart';
import 'package:flutter_map_app/src/repository/area_repository.dart';
import 'package:flutter_map_app/src/repository/user_settings_repository.dart';
import 'package:flutter_map_app/src/resources/constants.dart';
import 'package:flutter_map_app/src/utilities/helper.dart';

class BleCentralBloc extends Bloc {
  FlutterBlue _flutterBlue;
  List<BluetoothDevice> devices;
  bool isScanning = false;
  BluetoothDevice connectedDevice;

  final _scanResultController = StreamController<List<BluetoothDevice>>();
  Sink<List<BluetoothDevice>> get deviceList => _scanResultController.sink;
  Stream<List<BluetoothDevice>> get onDeviceListChange =>
      _scanResultController.stream;

  final _bluetoothStateController = StreamController<BluetoothState>();
  Sink<BluetoothState> get bluetoothState => _bluetoothStateController.sink;
  Stream<BluetoothState> get onBluetoothStateChange =>
      _bluetoothStateController.stream;

  final _scanningStateController = StreamController<bool>();
  Sink<bool> get scanningState => _scanningStateController.sink;
  Stream<bool> get onScanningStateChange => _scanningStateController.stream;

  final _statusController = StreamController<String>();
  Sink<String> get status => _statusController.sink;
  Stream<String> get onStatus => _statusController.stream;

  void updateDeviceList() {
    deviceList.add(devices);
  }

  void scan() {
    _flutterBlue
        .scan(
            scanMode: ScanMode.lowLatency,
            timeout: Duration(seconds: Constants.SCAN_TIMEOUT))
        .listen((result) {
      //print(result.device.name);
      if ((result.device.name != "") && (!devices.contains(result.device))) {
        devices.add(result.device);
        print(result.device.name);
        updateDeviceList();
      }
    }, onDone: () {
      _flutterBlue.stopScan();
      print("scan done");
      return;
    }, onError: (e) {
      _flutterBlue.stopScan();
      print("scan error");
      return;
    }, cancelOnError: true);
  }

  void connect(BluetoothDevice device) {
    if(isScanning){
      _flutterBlue.stopScan();
    }
    device.state.listen((state) {
      switch (state) {
        case BluetoothDeviceState.connecting:{

        }
          break;
        case BluetoothDeviceState.connected:{
           connectedDevice = device;
        }
          break;
        case BluetoothDeviceState.disconnecting:{

        }
          break;
        case BluetoothDeviceState.disconnected:
          {
            print("disconnected");
            connectedDevice = null;
            updateDeviceList();
          }
          break;
      }
    });

    print("connect to:[" + device.name + "]");
    device
        .connect(
            timeout: Duration(seconds: Constants.CONNECTION_TIMEOUT),
            autoConnect: false)
        .then((_) {
      print("connect success");
      updateDeviceList();
      device.discoverServices().then((serviceList) {

        serviceList.forEach((service) {
          service.characteristics.forEach((characteristic) {
            if(characteristic.uuid.toMac()==Guid(Constants.defaultCharacteristicUUID).toMac()){

              List<int> testBytes = List();
              for(int i=0; i<=49; i++){
                for(int j=0; j<=1023; j++){
                 testBytes.add(j);
                }
              }
              print("data to be send:$testBytes");


              UserSettings settings = UserSettings();
              settings.userId = "sendTest";
              String serialized = jsonEncode(settings);
              print(serialized);
              List<int> encodedByte = utf8.encode(serialized);

              sendBytesAsync(characteristic, encodedByte);

            }
          });
        });
      }, onError: (e) {
        print("service discover error");
      });
    }, onError: (e) {
      print("connect error");
    });
  }

  Future<void> sendBytesAsync(BluetoothCharacteristic characteristic, List<int> bytes)async{

    int length = bytes.length;
    int mtu = 20;

    int size = length ~/ mtu;

    List<List<int>> sendList = List();

    List<int> temp = List();
    for(int cnt=0; cnt <= size-1; cnt++){
      for(int num=0; num<=mtu-1; num++){
        temp.add(bytes[cnt*mtu+num]);
      }
      sendList.add(temp.toList());
      temp.clear();
    }

    for(int num = size*mtu; num <= length-1; num++){
      temp.add(bytes[num]);
    }
    if(temp.isNotEmpty) {
      sendList.add(temp.toList());
    }

    final header = Helper.intTo8BytesArray(sendList.length);
    await characteristic.write(header);

    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    int cnt = 0;
    Future.forEach(sendList, (bytes)async{
      await Future.delayed(Duration(milliseconds: 20));
      await characteristic.write(bytes,withoutResponse: true).then((value){
        print("wrote");
        print(sendList[cnt]);
        print("$cnt:${stopwatch.elapsedMilliseconds}[ms]");
        cnt++;
      }).catchError((err){
        print("err:${err.toString()}");
      });
    });

  }



  BleCentralBloc() {
    devices = new List();
    updateDeviceList();

    _flutterBlue = FlutterBlue.instance;
    scan();

    _flutterBlue.isScanning.listen((bool) {
      print("isScanning..." + bool.toString());
      isScanning = bool;
      if (bool) {
        status.add("スキャン中…");
      } else {
        status.add("下に引っ張って再スキャン");
      }
    });

    _flutterBlue.state.listen((state) {
      print("state:" + state.toString());
    });

    UserSettings settings = UserSettings();
    UserSettingsRepository().getTableData().then((value){

    });

//    Area area = Area();
//    var asea = AreaRepository().getTableList();
//
//    String serialized = jsonEncode(settings);
//
//    print(serialized);
//
//    List<int> encodedByte = utf8.encode(serialized);
//
//    print(encodedByte);
//
//    //*********************************************//
//
//    String decodedString = utf8.decode(encodedByte);
//
//    var deserialized = jsonDecode(decodedString);
//
//    print(deserialized);

  }

  @override
  void dispose() {
    _scanResultController.close();
    _bluetoothStateController.close();
    _scanningStateController.close();
    _statusController.close();
    _flutterBlue.stopScan();
    devices.clear();
  }
}
