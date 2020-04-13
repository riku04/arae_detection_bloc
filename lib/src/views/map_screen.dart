import 'dart:async';

import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_location/flutter_background_location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_app/src/blocs/map_bloc.dart';
import 'package:flutter_map_app/src/resources/constants.dart';
import 'package:flutter_map_app/src/utilities/logger.dart';
import 'package:flutter_map_app/src/widgets/space_box.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:math' as math;

import 'package:seekbar/seekbar.dart';
import 'package:vibration/vibration.dart';


class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin{
  MapController _mapController;
  Logger logger;

  AnimationController _controller;
  static const List<IconData> icons = const [Icons.clear,Icons.check];

  @override
  void initState(){
    super.initState();
    _mapController = MapController();
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  build(BuildContext context) {
    final blocMap = BlocProvider.of<MapBloc>(context);

    blocMap.setMapController(_mapController);

    blocMap.initLayers();
    blocMap.initMapOptions();
    blocMap.readSavedArea(Constants.DEFAULT_AREA_TABLE);


    blocMap.onSelectPolygon.listen((polygon){
      Vibration.hasVibrator().then((bool) {
        if (bool) {
          Vibration.vibrate(duration: 50);
        }
      });
      print("polygon pressed");
      showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Text(""),
              children: <Widget>[
                SimpleDialogOption(
                  child: Text("削除"),
                  onPressed: (){
                    blocMap.removePolygon(polygon);
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });

    return Scaffold(

      bottomNavigationBar: StreamBuilder(
        stream: blocMap.onLogPlayerVisibleChanged,
        builder: (context,logVisibleSnapshot){
          if(logVisibleSnapshot.data==true){

            return BottomAppBar(
              elevation: 9.0,
              color:  Colors.yellow,
              child:Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  StreamBuilder(
                    stream: blocMap.onLogPlayerStateChanged,
                    builder: (context,stateSnapshot){
                      Icon icon = Icon(
                          Icons.play_arrow,
                          color: Colors.grey
                      );
                      switch(stateSnapshot.data){
                        case Constants.LOG_PLAY_STOP:
                          icon = Icon(
                            Icons.play_arrow,
                            color: Colors.grey
                          );
                          break;
                        case Constants.LOG_PLAY_START:
                          icon = Icon(
                              Icons.stop,
                              color: Colors.grey
                          );
                          break;
                      }
                      return Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Column(children:<Widget>[
                              IconButton(
                                icon: Icon(
                                  Icons.fast_rewind,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  print("-1");
                                  blocMap.downPlaySpeed();
                                  },
                              ),
                              StreamBuilder(
                                stream: blocMap.onLogCurrentTime,
                                builder: (context,currentTimeSnapshot){
                                  if(currentTimeSnapshot.hasData){
                                    DateTime date = currentTimeSnapshot.data;
                                    var min = date.minute.toString();
                                    var sec = date.second.toString();
                                    if(date.minute<=9){
                                      min = "0" + date.minute.toString();
                                    }
                                    if(date.second <= 9){
                                      sec = "0" + date.second.toString();
                                    }
                                    return Text("${date.hour}:$min:$sec");
                                  }else{
                                    return Text("00:00:00");
                                  }
                                },
                              ),
                            ]
                            ),
                          ),
                          Expanded(child: new SizedBox()),
                          Column(children: <Widget>[
                            IconButton(
                              icon:icon,
                              onPressed: () {
                                //blocMap.logPlayerState.add(stateSnapshot.data);
                                blocMap.toggleLogPlaying();
                              },
                            ),
                            StreamBuilder(
                              stream: blocMap.onLogPlayerSpeed,
                              builder: (context,speedSnapshot){
                                if(speedSnapshot.hasData){
                                  return Text("x${speedSnapshot.data}",style: TextStyle(color: Colors.black));
                                }else{
                                  return SpaceBox(height: 1,width: 1);
                                }
                              },
                            )
                            //Text(status,style: TextStyle(color: Colors.grey),),
                          ],),
                          Expanded(child: new SizedBox()),
                          Column(children: <Widget>[
                            IconButton(
                              icon: Icon(
                                Icons.fast_forward,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                blocMap.upPlaySpeed();
                              },
                            ),
                            StreamBuilder(
                              stream: blocMap.onLogTotalTime,
                              builder: (context,totalTimeSnapshot){
                                if(totalTimeSnapshot.hasData){
                                  DateTime date = totalTimeSnapshot.data;
                                  var min = date.minute.toString();
                                  var sec = date.second.toString();
                                  if(date.minute<=9){
                                    min = "0" + date.minute.toString();
                                  }
                                  if(date.second <= 9){
                                    sec = "0" + date.second.toString();
                                  }
                                  return Text("${date.hour}:$min:$sec");
                                }else{
                                  return Text("00:00:00");
                                }
                              },
                            ),
                          ],
                          ),
                          SpaceBox(width: 10),
                        ],
                      );
                    },
                  ),
                  SpaceBox(height: 5,),
                  Padding(
                    padding: EdgeInsets.only(right: 30,left: 30,bottom: 15),
                    child:StreamBuilder(
                      stream: blocMap.onLogPlayerProgressUpdated,
                      builder: (context,progressSnapshot){
                        double progress;
                        if(progressSnapshot.hasData) {
                          progress = progressSnapshot.data;
                        }else{
                          progress = 0.0;
                        }
                        return SeekBar(
                          thumbColor: Colors.lightBlue,
                          progressColor: Colors.lightBlueAccent,
                          value: progress,
                          onProgressChanged: (value) {
                            blocMap.logPlayerProgress.add(value);
                            progress = value;
                          },
                          onStartTrackingTouch: (){
                            blocMap.stopLogPlaying();
                            //blocMap.logPlayerState.add(Constants.LOG_PLAY_STOP);

                            print("start");
                          },
                          onStopTrackingTouch: (){

                            //blocMap.startLogPlaying();
                            //blocMap.logPlayerState.add(Constants.LOG_PLAY_START);

                            print("stop");
                          },
                        );
                      },
                    ),
                  ),
                  SpaceBox(height: 5,),
                ],
              )

            );

          }else{
            return BottomAppBar(
            elevation: 9.0,
            //shape: CircularNotchedRectangle(),
            color: Colors.lightBlue,
            //notchMargin: 8.0,

            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[

                Padding(
                  padding: const EdgeInsets.all(6),
                  child: IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Scaffold.of(this.context).openDrawer();
                      },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(6),
                  child: IconButton(
                    icon: StreamBuilder(
                    stream: blocMap.onAlertEnableChanged,
                    builder: (context,alertEnableSnapshot){
                      if(alertEnableSnapshot.hasData){
                        print("alert enable changed: ${alertEnableSnapshot.data}");
                        if(alertEnableSnapshot.data){
                          return Icon(
                            Icons.alarm_on,
                            color: Colors.white,
                          );
                        }else{
                          return Icon(
                            Icons.alarm_off,
                            color: Colors.white,
                          );
                        }
                      }else{
                        return Icon(
                          Icons.alarm_off,
                          color: Colors.white,
                        );
                      }

                    }),
                    onPressed: () {
                      blocMap.toggleAlertEnable();
                      },
                  ),
                ),

                Expanded(child: new SizedBox()),
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      String key = "";
                      showDialog(
                          barrierDismissible: false,
                          context: this.context,
                          builder: (context){
                            return AlertDialog(
                              content: Container(
                                height: 80,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    TextField(
                                      onChanged: (string){
                                        key = string;
                                      },
                                    ),
                                    StreamBuilder(
                                      stream: blocMap.onIsSearchingChanged,
                                      builder: (context,isSearchingsnapshot){
                                        if(isSearchingsnapshot.hasData){
                                          if(isSearchingsnapshot.data == true){
                                            return LinearProgressIndicator();
                                          }else{
                                            return SpaceBox(height: 1,width: 1,);
                                          }
                                        }else{
                                          return SpaceBox(height: 1,width: 1,);
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("Search"),
                                  onPressed: () async {
                                    await blocMap.searchAndMoveToPlace(key);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          }
                      );
                    },
                  ),
                ),

                IconButton(
                  icon: Stack(
                    children: <Widget>[
                      Center(
                        child:StreamBuilder(
                          stream: blocMap.onCalcLocationChanged,
                          builder: (context,calcStateSnapshot){
                            if(calcStateSnapshot.hasData){

//                              Future.delayed(Duration(seconds: 10),(){
//                                blocMap.calcLocation.add(false);
//                              });

                              if(calcStateSnapshot.data == true){
                                return CircularProgressIndicator(backgroundColor: Colors.pinkAccent,strokeWidth: 3,);
                              }else{
                                return SpaceBox(height: 1,width: 1,);
                              }
                            }else{
                              return SpaceBox(height: 1,width: 1,);
                            }
                        },
                        )
                      ),
                      Center(
                        child:Icon(
                          Icons.location_searching,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    blocMap.calcLocation.add(true);
                    blocMap.onCurrentLocationChanged.listen((point){
                      if(blocMap.isCalcLocationEnable) {
                        _mapController.move(point, _mapController.zoom);
                      }
                    });
                  },
                ),
                SpaceBox(width: 10),
              ],
            )
            );
          }
        },
      ),




        body: Stack(
          children: <Widget>[
            Container(
              child: StreamBuilder<MapOptions>(
                stream: blocMap.onInitOptions,
                builder: (context, optionsSnapshot) {
                  return StreamBuilder<List<LayerOptions>>(
                    stream: blocMap.onLayersChanged,
                    builder: (context, layersSnapshot) {
                      return FlutterMap(
                        options: optionsSnapshot.data,
                        mapController: _mapController,
                        layers: layersSnapshot.data,
                      );
                      },
                  );
                  },
              ),
            ),

            Center(child: Icon(Icons.add_circle_outline,size: 40.0,),),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      "©︎OpenStreetMap contributors",
                      style: TextStyle(fontSize: 10),
                    )
                  ],
                )
              ],
            ),


          ],
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        floatingActionButton: StreamBuilder(
          stream: blocMap.onLogPlayerVisibleChanged,
          builder: (context,stateSnapshot){
            if(stateSnapshot.data==true){

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SpaceBox(height: 1,width: 100,),
                          Card(
                            child: Padding(
                                padding: EdgeInsets.all(10),
                                child: StreamBuilder(
                                  stream: blocMap.onLogStatusChanged,
                                  builder: (context,logStatusSnapshot){
                                    if(logStatusSnapshot.hasData){
                                      if(logStatusSnapshot.data == Constants.OUTSIDE){
                                        return Text("判定：領域外",
                                            style: TextStyle(
                                                fontSize: 20,
                                                backgroundColor: Colors.greenAccent
                                            )
                                        );
                                      }else if(logStatusSnapshot.data == Constants.CLOSE){
                                        return Text("判定：領域接近",
                                            style: TextStyle(
                                                fontSize: 20,
                                                backgroundColor: Colors.yellowAccent
                                            )
                                        );
                                      }else if(logStatusSnapshot.data == Constants.INSIDE){
                                        return Text("判定：領域内",
                                            style: TextStyle(
                                                fontSize: 20,
                                                backgroundColor: Colors.pinkAccent
                                            )
                                        );
                                      }
                                    }
                                  return Text("STATUS",style: TextStyle(fontSize: 40));
                              },)
                            ),
                          ),
                          SpaceBox(width: 30,),
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: FloatingActionButton(
                              heroTag: null,
                              backgroundColor: Colors.yellow,
                              mini: true,
                              child: new Icon(Icons.close, color: Colors.grey),
                              onPressed: (){
                                blocMap.logPlayerVisible.add(false);
                                },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );



            }else{
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: new List.generate(icons.length, (int index) {
                  Widget child = new Container(
                    height: 70.0,
                    width: 56.0,
                    alignment: FractionalOffset.topCenter,
                    child: new ScaleTransition(
                      scale: new CurvedAnimation(
                        parent: _controller,
                        curve: new Interval(
                            0.0,
                            1.0 - index / icons.length / 2.0,
                            curve: Curves.easeOut
                        ),
                      ),
                      child: new FloatingActionButton(
                        heroTag: null,
                        backgroundColor:  Colors.pinkAccent,
                        mini: true,
                        child: new Icon(icons[index], color: Colors.white),
                        onPressed: (){
                          print("icon index:"+index.toString());
                          if(index==1){
                            blocMap.createPolygon().then((_){
                              blocMap.removeAreaByAreaName(Constants.DEFAULT_AREA_TABLE).then((_){
                                blocMap.saveCurrentArea(Constants.DEFAULT_AREA_TABLE);
                              });
                            });
                          }else if(index==0){
                            blocMap.removeDraftPolygon();
                          }
                          _controller.reverse();
                        },
                      ),
                    ),
                  );
                  return child;
                }).toList()..add(
                    Container(
                      margin: EdgeInsets.only(bottom: 16.0),
                      child: new FloatingActionButton(
                        backgroundColor: Colors.indigo,
                        heroTag: "add",
                        child: new AnimatedBuilder(
                          animation: _controller,
                          builder: (BuildContext context, Widget child) {
                            return new Transform(
                              transform: new Matrix4.rotationZ(_controller.value * 0 * math.pi),
                              alignment: FractionalOffset.center,
                              child: new Icon(Icons.add_location),
                            );
                          },
                        ),
                        onPressed: () {
                          //if (_controller.isDismissed) {
                          blocMap.addPoint.add(_mapController.center);
                          blocMap.onAddPoint.listen((_){
                            if(blocMap.isPolygonReady){ // ポリゴン生成可能なら
                              _controller.forward();
                            } else {
                              _controller.reverse();
                            }
                          });
                        },
                      ),
                    )
                ),
              );
            }
          },
        )
    );
  }
}
