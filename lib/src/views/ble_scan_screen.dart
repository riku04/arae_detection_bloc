import 'dart:async';

import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_map_app/src/blocs/ble_scan_bloc.dart';
import 'package:flutter_map_app/src/blocs/map_bloc.dart';
import 'package:flutter_map_app/src/resources/constants.dart';
import 'package:flutter_map_app/src/widgets/space_box.dart';

class BleScanScreen extends StatefulWidget {
  @override
  _BleScanScreenState createState() => _BleScanScreenState();
}

class _BleScanScreenState extends State<BleScanScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  build(BuildContext context) {
    final mapBloc = BlocProvider.of<MapBloc>(context);
    final bleScanBloc = BlocProvider.of<BleScanBloc>(context);

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text("SCAN DEVICES")),
      body: StreamBuilder<List<BluetoothDevice>>(
        stream: bleScanBloc.onDeviceList,
        builder: (context, deviceSnapshot) {
          if (!deviceSnapshot.hasData) {
            return Scaffold();
          }

          return RefreshIndicator(
            onRefresh: () async {
              bleScanBloc.scan();
              await Future.delayed(
                  new Duration(seconds: Constants.SCAN_TIMEOUT));
            },
            child: Scrollbar(
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  Color color = Colors.white;
                  Widget progress = SpaceBox(
                    width: 1,
                    height: 1,
                  );
                  if ((bleScanBloc.connectedDevice != null) &&
                      (bleScanBloc.connectedDevice ==
                          deviceSnapshot.data[index])) {
                    color = Colors.greenAccent;
                    progress = CircularProgressIndicator();
                  }

                  return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SpaceBox(
                          height: 2.0,
                        ),
                        Row(
                          children: <Widget>[
                            SpaceBox(
                              width: 5.0,
                            ),
                            Row(
                              children: <Widget>[
                                OutlineButton(
                                  color: color,
                                  child: Padding(
                                    child: Text(
                                      deviceSnapshot.data[index].name,
                                      style: TextStyle(fontSize: 22.0),
                                    ),
                                    padding: EdgeInsets.all(15.0),
                                  ),
                                  onPressed: () {
                                    print("device name pressed:" +
                                        deviceSnapshot.data[index].name);
                                    bleScanBloc
                                        .connect(deviceSnapshot.data[index]);
                                  },
                                ),
                                SpaceBox(
                                  width: 5,
                                ),
                                progress,
                              ],
                            ),
                            SpaceBox(
                              width: 5.0,
                            ),
                          ],
                        ),
                        SpaceBox(height: 2.0)
                      ]);
                },
                itemCount: deviceSnapshot.data.length,
              ),
            ),
          );
        },
      ),
    ));
  }
}
