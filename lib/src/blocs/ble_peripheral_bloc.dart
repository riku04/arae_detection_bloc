import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_map_app/src/utilities/helper.dart';

class BlePeripheralBloc extends Bloc {

  FlutterBlePeripheral flutterBlePeripheral;

//  String serviceUuid = "eee1d584-5a3c-4f6b-9547-eda40ecf0ed8";
//  String characteristicUuid = "fff1d584-5a3c-4f6b-9547-eda40ecf0ed8";

  bool isAdvertising = false;

  bool isReceiving = false;
  int expectedReceiveTimes = 0;
  List<int> buffer;
  int receiveCounter = 0;

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

  final _receivedValueController = StreamController<Uint8List>();
  Sink<Uint8List> get receivedValue => _receivedValueController.sink;
  Stream<Uint8List> get onReceivedValue => _receivedValueController.stream;

  BlePeripheralBloc(){
    print("ble_peripheral_bloc");
    init();
  }

  Future<void> init() async {
    flutterBlePeripheral = FlutterBlePeripheral();
    //await flutterBlePeripheral.init(serviceUuid, characteristicUuid); //バグってるので非推奨、defaultの値で固定。

    flutterBlePeripheral.onReceived().listen((bytes) {

      if(this.isReceiving==false){
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

          String decodedString = utf8.decode(buffer);
          var deserialized = jsonDecode(decodedString);
          print(deserialized);

          this.isReceiving = false;
          this.buffer.clear();
        }
      }
    });
    return;
  }

  Future<void> startAdvertise(String localName)async{
   await flutterBlePeripheral.startAdvertising(localName);
   status.add("advertising...");
   return;
  }

  Future<void> stopAdvertise()async{
    await flutterBlePeripheral.stopAdvertising();
    status.add("");
    return;
  }

  @override
  void dispose() {
    _bluetoothStateController.close();
    _advertisingStateController.close();
    _statusController.close();
    _receivedValueController.close();
  }

}