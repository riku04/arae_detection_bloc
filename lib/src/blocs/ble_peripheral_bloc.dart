import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_map_app/src/models/area.dart';
import 'package:flutter_map_app/src/models/user_settings.dart';
import 'package:flutter_map_app/src/repository/area_repository.dart';
import 'package:flutter_map_app/src/repository/user_settings_repository.dart';
import 'package:flutter_map_app/src/resources/constants.dart';
import 'package:flutter_map_app/src/utilities/helper.dart';
import 'package:flutter_map_app/src/blocs/map_bloc.dart';


class BlePeripheralBloc extends Bloc {

  FlutterBlePeripheral flutterBlePeripheral;
  MapBloc blocMap;
  BuildContext context;

//  String serviceUuid = "eee1d584-5a3c-4f6b-9547-eda40ecf0ed8";
//  String characteristicUuid = "fff1d584-5a3c-4f6b-9547-eda40ecf0ed8";

  bool isAdvertising = false;
  bool isReceiving = false;
  int receivingDataType = 0;
  int expectedReceiveTimes = 0;
  List<int> buffer;
  int receiveCounter = 0;

  BluetoothDevice connectedDevice;

  final _bluetoothStateController = StreamController<BluetoothState>();
  Sink<BluetoothState> get bluetoothState => _bluetoothStateController.sink;
  Stream<BluetoothState> get onBluetoothStateChange => _bluetoothStateController.stream;

  final _advertisingStateController = StreamController<bool>();
  Sink<bool> get advertisingState => _advertisingStateController.sink;
  Stream<bool> get onAdvertisingStateChange => _advertisingStateController.stream;

  final _statusController = StreamController<String>();
  Sink<String> get status => _statusController.sink;
  Stream<String> get onStatus => _statusController.stream;

  final _receivedValueController = StreamController<Uint8List>();
  Sink<Uint8List> get receivedValue => _receivedValueController.sink;
  Stream<Uint8List> get onReceivedValue => _receivedValueController.stream;

  BlePeripheralBloc(BuildContext context){
    this.context = context;
    blocMap = BlocProvider.of<MapBloc>(context);
    print("ble_peripheral_bloc");
    init();
  }

  Future<void> init() async {
    flutterBlePeripheral = FlutterBlePeripheral();
    //await flutterBlePeripheral.init(serviceUuid, characteristicUuid); //バグってるので非推奨、defaultの値で固定。

    flutterBlePeripheral.onReceived().listen((bytes) {

      if(isAdvertising){
        stopAdvertise();
      }

      if(this.receivingDataType == 0){
        switch(bytes[0]){
          case Constants.SEND_TYPE_AREA:
            print("receiving area");
            receivingDataType = Constants.SEND_TYPE_AREA;
            break;

          case Constants.SEND_TYPE_SETTINGS:
            print("receiving settings");
            receivingDataType = Constants.SEND_TYPE_SETTINGS;
            break;

          case Constants.SEND_END:
            stopAdvertise();
            print("receiving end");
            status.add("complete");
            //close this dialog
            break;
        }
      }

      else if(this.isReceiving==false){
        this.isReceiving = true;

        List<dynamic> l = bytes;
        l = l.map((e) => e as int).toList();
        this.expectedReceiveTimes = Helper.bytesToInteger(l);//20 is mtu

      } else {

        if(this.buffer==null){
          this.buffer = List();
        }

        List<dynamic> temp = bytes;
        temp = temp.map((e) => e as int).toList();
        temp.forEach((byte) {
          this.buffer.add(byte);
        });
        receiveCounter++;

        status.add("${this.receiveCounter}/${this.expectedReceiveTimes}");
        print("expected:${this.expectedReceiveTimes}");
        print("received:${this.receiveCounter}");

        if(this.receiveCounter == this.expectedReceiveTimes){
          print("receive complete");

          switch(this.receivingDataType){
            case Constants.SEND_TYPE_AREA: //area data
              String decodedString = utf8.decode(buffer);
              var deserialized = jsonDecode(decodedString);
              Area area = Area();
              area.fromJson(deserialized);
              AreaRepository().addDataToTable(Constants.DEFAULT_AREA_TABLE, area);

              this.isReceiving = false;
              this.receiveCounter = 0;
              this.expectedReceiveTimes = 0;
              this.receivingDataType = 0;
              this.buffer.clear();

              break;
            case Constants.SEND_TYPE_SETTINGS: //settings data
              String decodedString = utf8.decode(buffer);
              var deserialized = jsonDecode(decodedString);
              print(deserialized);
              UserSettings settings = UserSettings();
              settings.fromJson(deserialized);
              print("settings received:${settings.userId.toString()},${settings.groupId.toString()}");
              UserSettingsRepository().setTableData(settings);

              this.isReceiving = false;
              this.receiveCounter = 0;
              this.expectedReceiveTimes = 0;
              this.receivingDataType = 0;
              this.buffer.clear();

              break;
          }

          blocMap.readSavedArea(Constants.DEFAULT_AREA_TABLE);

        }
      }
    });
    return;
  }

  Future<void> startAdvertise(String localName)async{
   await flutterBlePeripheral.startAdvertising(localName);
   isAdvertising = true;
   status.add("advertising...");
   return;
  }

  Future<void> stopAdvertise()async{
    await flutterBlePeripheral.stopAdvertising();
    isAdvertising = false;
    status.add("");
    return;
  }

  @override
  void dispose() {
    stopAdvertise();
    _bluetoothStateController.close();
    _advertisingStateController.close();
    _statusController.close();
    _receivedValueController.close();
  }

}