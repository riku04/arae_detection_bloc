import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_map_app/src/blocs/ble_central_bloc.dart';
import 'package:flutter_map_app/src/blocs/map_bloc.dart';
import 'package:flutter_map_app/src/repository/user_settings_repository.dart';
import 'package:flutter_map_app/src/resources/constants.dart';
import 'package:flutter_map_app/src/widgets/space_box.dart';

class BleCentralScreen extends StatefulWidget {
  @override
  _BleCentralScreenState createState() => _BleCentralScreenState();
}

class _BleCentralScreenState extends State<BleCentralScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  build(BuildContext context) {
    final mapBloc = BlocProvider.of<MapBloc>(context);
    final bleCentralBloc = BlocProvider.of<BleCentralBloc>(context);

    return SafeArea(
        child: WillPopScope(
            onWillPop: () {
              print("will back");
              Navigator.of(context).pop();
              return Future.value(false);
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text("SCAN DEVICES"),
                bottom: PreferredSize(
                  child: StreamBuilder(
                    stream: bleCentralBloc.onStatus,
                    builder: (context, statusSnapshot) {
                      if (statusSnapshot.hasData) {
                        return Text(
                          statusSnapshot.data,
                          style: TextStyle(color: Colors.white),
                        );
                      } else {
                        return Text("");
                      }
                    },
                  ),
                  preferredSize: null,
                ),
              ),
              body: StreamBuilder<List<BluetoothDevice>>(
                stream: bleCentralBloc.onDeviceListChange,
                builder: (context, deviceSnapshot) {
                  if (!deviceSnapshot.hasData) {
                    return Scaffold();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      bleCentralBloc.scan();
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
                          if ((bleCentralBloc.connectedDevice != null) &&
                              (bleCentralBloc.connectedDevice ==
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
                                        FlatButton(
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
                                                deviceSnapshot
                                                    .data[index].name);

                                            TextEditingController _userIdController = TextEditingController();
                                            TextEditingController _groupIdController = TextEditingController();
                                            UserSettingsRepository().getTableData().then((value){
                                              _userIdController.text = value["USER_ID"];
                                              _groupIdController.text = value["GROUP_ID"];
                                            });

                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text("input user name"),
                                                    content: Column(
                                                      children: <Widget>[
                                                        Text("user id:"),
                                                        TextField(controller: _userIdController,),
                                                        Text("group id"),
                                                        TextField(controller: _groupIdController,),
                                                      ],
                                                    ),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        child: Text("OK"),
                                                        onPressed: () {
                                                          if (_userIdController.text.isEmpty || _groupIdController.text.isEmpty) {
                                                            return;
                                                          }
                                                          print("user id:" + _userIdController.text);
                                                          print("group id:"+ _groupIdController.text);

                                                          bleCentralBloc.connect(deviceSnapshot.data[index],_userIdController.text,_groupIdController.text);

                                                          Navigator.of(context).pop();
                                                        },
                                                      ),
                                                      FlatButton(
                                                        child: Text("CANCEL"),
                                                        onPressed: () {
                                                          _userIdController.clear();
                                                          _groupIdController.clear();
                                                          Navigator.of(context).pop();
                                                        },
                                                      )
                                                    ],
                                                  );
                                                });


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
            )));
  }
}
