import 'dart:math';

import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_app/src/blocs/map_bloc.dart';
import 'package:flutter_map_app/src/blocs/read_area_bloc.dart';
import 'package:flutter_map_app/src/blocs/read_log_bloc.dart';
import 'package:flutter_map_app/src/models/log_data.dart';
import 'package:flutter_map_app/src/widgets/space_box.dart';

class ReadLogScreen extends StatefulWidget {
  @override
  _ReadLogScreenState createState() => _ReadLogScreenState();
}

class _ReadLogScreenState extends State<ReadLogScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  build(BuildContext context) {
    final blocMap = BlocProvider.of<MapBloc>(context);
    final readLogBloc = BlocProvider.of<ReadLogBloc>(context);

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("移動履歴確認"),
          ),
          body:StreamBuilder<List<List<String>>>(
            stream: readLogBloc.onLogList,
            builder: (context, logSnapshot) {
              if (!logSnapshot.hasData) {
                return Scaffold();
              }

              return ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
                    SpaceBox(
                      height: 2.0,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          SpaceBox(
                            width: 5.0,
                          ),
                          OutlineButton(
                            child: Padding(
                              child: Column(children: <Widget>[
                                Text(
                                  logSnapshot.data[index][0],
                                  style: TextStyle(fontSize: 15.0),
                                ),
                                SpaceBox(height: 3,),
                                Text(
                                  "${logSnapshot.data[index][1]}[KB]",
                                  style: TextStyle(fontSize: 10.0),
                                ),
//                                StreamBuilder(
//                                  stream: readLogBloc.onSizeList,
//                                  builder: (context,sizeSnapshot) {
//                                    if (sizeSnapshot.hasData) {
//                                      return Text(
//                                        sizeSnapshot.data[index].toString(),
//                                        style: TextStyle(fontSize: 10.0),
//                                      );
//                                    }else{
//                                      return SpaceBox(width: 1,height: 1,);
//                                    }
//                                  }
//                                )

                              ],),
                              padding: EdgeInsets.all(5.0),
                            ),
                            onPressed: (){
                              print("log name pressed:" + logSnapshot.data[index][0]);

                              readLogBloc.readLogDataByName(logSnapshot.data[index][0]).then((logData){
                                print(logData);
                                blocMap.setLogData(logData);
                              });

                              //readLogBloc.openOnAnotherApp(logSnapshot.data[index]);
                              //blocMap.readSavedArea(logSnapshot.data[index]);

                              Navigator.of(context).pop();
                            },
                            onLongPress: (){


                              readLogBloc.openOnAnotherApp(logSnapshot.data[index][0]);

//                            showDialog(
//                              context: context,
//                              builder: (_) {
//                                return AlertDialog(
//                                  title: Text("履歴データ削除"),
//                                  content:
//                                  Text(logSnapshot.data[index] + "を削除します"),
//                                  actions: <Widget>[
//                                    // ボタン領域
//                                    FlatButton(
//                                      child: Text("Cancel"),
//                                      onPressed: () => Navigator.pop(context),
//                                    ),
//                                    FlatButton(
//                                      child: Text("OK"),
//                                      onPressed: () {
//                                        print("delete pressed:" + logSnapshot.data[index]);
//                                        readLogBloc.removeLogByName(logSnapshot.data[index]);
//                                        Navigator.pop(context);
//                                      },
//                                    ),
//                                  ],
//                                );
//                              },
//                            );

                            },
                          ),
                          SpaceBox(
                            width: 5.0,
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) {
                                  return AlertDialog(
                                    title: Text("履歴データ削除"),
                                    content:
                                    Text(logSnapshot.data[index][0] + "を削除します"),
                                    actions: <Widget>[
                                      // ボタン領域
                                      FlatButton(
                                        child: Text("Cancel"),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      FlatButton(
                                        child: Text("OK"),
                                        onPressed: () {
                                          print("delete pressed:" + logSnapshot.data[index][0]);
                                          readLogBloc.removeLogByName(logSnapshot.data[index][0]);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          )
                        ],
                      ),
                    ),

                    SpaceBox(height: 2.0)
                  ]);
                },
                itemCount: logSnapshot.data.length,
              );
            },
          ),
        ));
  }
}
