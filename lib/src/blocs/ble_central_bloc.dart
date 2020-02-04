import 'dart:async';

import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_map_app/src/resources/constants.dart';

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
      print(result.device.name);
      if ((result.device.name != "") && (!devices.contains(result.device))) {
        devices.add(result.device);
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
    device.state.listen((state) {
      switch (state) {
        case BluetoothDeviceState.connecting:
          {}
          break;
        case BluetoothDeviceState.connected:
          {
            connectedDevice = device;
          }
          break;
        case BluetoothDeviceState.disconnecting:
          {}
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
        print("service discover success");
        serviceList[0].characteristics[0].write([5, 4, 3, 2, 1]).then((_) {
          print("characteristic write success");
          device.disconnect();
        }, onError: (e) {
          print("characteristic write error");
        });
      }, onError: (e) {
        print("service discover error");
      });
    }, onError: (e) {
      print("connect error");
    });
  }

  BleCentralBloc() {
    devices = new List();
    updateDeviceList();

    _flutterBlue = FlutterBlue.instance;
    scan();

    _flutterBlue.isScanning.listen((bool) {
      print("isScanning..." + bool.toString());
      if (bool) {
        status.add("スキャン中…");
      } else {
        status.add("下に引っ張って再スキャン");
      }
    });

    _flutterBlue.state.listen((state) {
      print("state:" + state.toString());
    });
  }

  @override
  void dispose() {
    _scanResultController.close();
    _bluetoothStateController.close();
    _scanningStateController.close();
    _statusController.close();
    _flutterBlue.stopScan();
  }
}
