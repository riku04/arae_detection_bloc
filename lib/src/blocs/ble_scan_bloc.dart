import 'dart:async';

import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_map_app/src/resources/constants.dart';

class BleScanBloc extends Bloc {
  FlutterBlue flutterBlue;
  List<BluetoothDevice> devices;
  bool isScanning = false;
  BluetoothDevice connectedDevice;

  final _scanResultController = StreamController<List<BluetoothDevice>>();
  Sink<List<BluetoothDevice>> get deviceList => _scanResultController.sink;
  Stream<List<BluetoothDevice>> get onDeviceList =>
      _scanResultController.stream;

  final _refreshController = StreamController<void>();
  Sink<void> get refresh => _refreshController.sink;
  Stream<void> get onRefresh => _refreshController.stream;

  void updateDeviceList() {
    deviceList.add(devices);
  }

  void stopScan() {
    flutterBlue.stopScan();
  }

  void scan() {
    flutterBlue
        .scan(
            scanMode: ScanMode.lowLatency,
            timeout: Duration(seconds: Constants.SCAN_TIMEOUT))
        .listen((result) {
      print(result.device.name);
      if ((result.device.name != "") & (!devices.contains(result.device))) {
        devices.add(result.device);
        updateDeviceList();
      }
    }, onDone: () {
      flutterBlue.stopScan();
      print("scan done");
      return;
    }, onError: (e) {
      flutterBlue.stopScan();
      print("scan error");
      return;
    });
  }

  void connect(BluetoothDevice device) {
    connectedDevice = device;
    connectedDevice.state.listen((state) {
      if (state == BluetoothDeviceState.disconnected) {
        print("disconnected");
        connectedDevice = null;
        updateDeviceList();
      }
    });
    print("connect to:[" + device.name + "]");
    connectedDevice
        .connect(
            timeout: Duration(seconds: Constants.CONNECTION_TIMEOUT),
            autoConnect: false)
        .then((_) {
      print("connect success");
      updateDeviceList();
      connectedDevice.discoverServices().then((serviceList) {
        print("service discover success");
        serviceList[0].characteristics[0].write([5, 4, 3, 2, 1]).then((_) {
          print("characteristic write success");
          connectedDevice.disconnect();
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

  BleScanBloc() {
    devices = new List();
    updateDeviceList();
    flutterBlue = FlutterBlue.instance;
    scan();
    flutterBlue.isScanning.listen((bool) {
      isScanning = bool;
      print("isScanning..." + bool.toString());
    });
    flutterBlue.state.listen((state) {
      print("state:" + state.toString());
    });
  }

  @override
  void dispose() {
    _scanResultController.close();
    _refreshController.close();
    flutterBlue.stopScan();
  }
}
