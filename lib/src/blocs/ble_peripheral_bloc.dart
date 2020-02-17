import 'dart:async';

import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BlePeripheralBloc extends Bloc {

  FlutterBlePeripheral flutterBlePeripheral;

  String serviceUuid = "eee1d584-5a3c-4f6b-9547-eda40ecf0ed8";
  String characteristicUuid = "fff1d584-5a3c-4f6b-9547-eda40ecf0ed8";

  bool isAdvertising = false;
  BluetoothDevice connectedDevice;

  final _bluetoothStateController = StreamController<BluetoothState>();
  Sink<BluetoothState> get bluetoothState => _bluetoothStateController.sink;
  Stream<BluetoothState> get onBluetoothStateChange => _bluetoothStateController.stream;

  final _advertisingStateController = StreamController<bool>();
  Sink<bool> get scanningState => _advertisingStateController.sink;
  Stream<bool> get onScanningStateChange => _advertisingStateController.stream;

  final _statusController = StreamController<String>();
  Sink<String> get status => _statusController.sink;
  Stream<String> get onStatus => _statusController.stream;

  BlePeripheralBloc(){
    print("ble_peripheral_bloc");
    init();
//    flutterBlePeripheral = FlutterBlePeripheral();
//     flutterBlePeripheral.init(serviceUuid, characteristicUuid);
//    flutterBlePeripheral.startAdvertising("flutter01").then((value){
//      status.add("advertising...");
//    });
//    flutterBlePeripheral.onReceived().listen((event) {
//      status.add(event.toString());
//    });
  }

  void init() async {
    flutterBlePeripheral = FlutterBlePeripheral();
    //await flutterBlePeripheral.init(serviceUuid, characteristicUuid); //バグってるので非推奨、defaultの値で固定。
    await flutterBlePeripheral.startAdvertising("flutter03");
    status.add("advertising...");
    flutterBlePeripheral.onReceived().listen((event) {
      status.add(event.toString());
    });
  }

  void advertise(){

  }

  @override
  void dispose() {
    _bluetoothStateController.close();
    _advertisingStateController.close();
    _statusController.close();
  }

}