import 'package:bloc_provider/bloc_provider.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_app/src/blocs/map_bloc.dart';
import 'package:flutter_map_app/src/blocs/setting_bloc.dart';
import 'package:flutter_map_app/src/models/user_settings.dart';
import 'package:flutter_map_app/src/widgets/space_box.dart';
import 'package:numberpicker/numberpicker.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
   build(BuildContext context){
    final mapBloc = BlocProvider.of<MapBloc>(context);
    final blocSetting = BlocProvider.of<SettingBloc>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("SETTING"),
        actions: <Widget>[
          FlatButton(
            child: Text("保存",style: TextStyle(color: Colors.white),),
            onPressed: (){
              print("setting save pressed");
              blocSetting.save().then((settings){
                mapBloc.settings.add(settings);
              });
            },
          )
        ],),
        body:ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[

            SpaceBox(height: 10,),
            ExpandablePanel(
              header: Center(child: Text("ユーザー設定")),
              expanded: Column(
                children: <Widget>[
                  Container(
                    height: 60,
                    child: Row(
                      children: <Widget>[
                        SpaceBox(width: 20,),
                        Text("USER ID"),
                        SpaceBox(width: 20,),
                        Container(
                          height: 60,
                          width: 120,
                          child: StreamBuilder(
                            stream: blocSetting.onUserId,
                            builder: (context,snapshot){
                              print("data:"+snapshot.data.toString());
                              if(snapshot.hasData) {
                                return TextFormField(
                                  initialValue: snapshot.data,
                                  onChanged: (string){
                                    print(string);
                                    blocSetting.setTempUserId(string);
                                  },
                                );
                              }else{
                                return Container();
                              }
                            },
                          )
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 60,
                    child: Row(
                      children: <Widget>[
                        SpaceBox(width: 20,),
                        Text("GROUP ID"),
                        SpaceBox(width: 20,),
                        Container(
                          height: 60,
                          width: 120,
                          child: StreamBuilder(
                            stream: blocSetting.onGroupId,
                            builder: (context,snapshot){
                              print("data:"+snapshot.data.toString());
                              if(snapshot.hasData) {
                                return TextFormField(
                                  initialValue: snapshot.data,
                                  onChanged: (string){
                                    print(string);
                                    blocSetting.setTempGroupId(string);
                                  },
                                );
                              }else{
                                return Container();
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 60,
                    child: Row(
                      children: <Widget>[
                        SpaceBox(width: 20,),
                        Text("管理者権限"),
                        SpaceBox(width: 20,),
                        Container(
                          height: 60,
                          width: 60,

                          child: StreamBuilder(
                            stream: blocSetting.onAdmin,
                            builder: (context,snapshot){
                              print("data:"+snapshot.data.toString());
                              if(snapshot.hasData) {

                                bool admin = false;
                                if(snapshot.data == 1){
                                  admin = true;
                                }

                                return Switch(
                                  value: admin,
                                  onChanged: (bool){
                                    if(bool){
                                      blocSetting.setTempAdmin(1);
                                      blocSetting.admin.add(1);//onChangeはvalueとの差分で判定されるので再生成しないと反応しなくなる
                                      admin = true;
                                    }else if(!bool){
                                      blocSetting.setTempAdmin(0);
                                      blocSetting.admin.add(0);
                                      admin = false;
                                    }
                                  },
                                );
                              }else{
                                return Container();
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(),
            ExpandablePanel(
              header: Center(child: Text("警報設定")),
              expanded: Column(
                children: <Widget>[
                  Container(
                    height: 60,
                    child: Row(
                      children: <Widget>[
                        SpaceBox(width: 20,),
                        Text("侵入時警報"),
                        SpaceBox(width: 20,),
                        Container(
                          height: 60,
                          width: 60,
                          child: StreamBuilder(
                            stream: blocSetting.onEnterAlertON,
                            builder: (context,snapshot){
                              print("data:"+snapshot.data.toString());
                              if(snapshot.hasData) {
                                bool enterAlertOn = false;
                                if(snapshot.data == 1){
                                  enterAlertOn = true;
                                }
                                return Switch(
                                  value: enterAlertOn,
                                  onChanged: (bool){
                                    if(bool){
                                      blocSetting.setTempEnterAlertOn(1);
                                      blocSetting.enterAlertOn.add(1);
                                    }else{
                                      blocSetting.setTempEnterAlertOn(0);
                                      blocSetting.enterAlertOn.add(0);
                                    }
                                  },
                                );
                              }else{
                                return Container();
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 60,
                    child: Row(
                      children: <Widget>[
                        SpaceBox(width: 20,),
                        Text("接近時警報"),
                        SpaceBox(width: 20,),
                        Container(
                          height: 60,
                          width: 60,
                          child: StreamBuilder(
                            stream: blocSetting.onCloseAlertOn,
                            builder: (context,snapshot){
                              print("data:"+snapshot.data.toString());
                              if(snapshot.hasData) {
                                bool closeAlertOn = false;
                                if(snapshot.data == 1){
                                  closeAlertOn = true;
                                }
                                return Switch(
                                  value: closeAlertOn,
                                  onChanged: (bool){
                                    if(bool){
                                      blocSetting.setTempCloseAlertOn(1);
                                      blocSetting.closeAlertOn.add(1);
                                    }else{
                                      blocSetting.setTempCloseAlertOn(0);
                                      blocSetting.closeAlertOn.add(0);
                                    }
                                  },
                                );
                              }else{
                                return Container();
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 60,
                    child: Row(
                      children: <Widget>[
                        SpaceBox(width: 20,),
                        Text("振動オン"),
                        SpaceBox(width: 20,),
                        Container(
                          height: 60,
                          width: 60,
                          child: StreamBuilder(
                            stream: blocSetting.onVibrationOn,
                            builder: (context,snapshot){
                              print("data:"+snapshot.data.toString());
                              if(snapshot.hasData) {
                                bool vibrationOn = false;
                                if(snapshot.data == 1){
                                  vibrationOn = true;
                                }
                                return Switch(
                                  value: vibrationOn,
                                  onChanged: (bool){
                                    if(bool){
                                      blocSetting.setTempVibrationOn(1);
                                      blocSetting.vibrationOn.add(1);
                                    }else{
                                      blocSetting.setTempVibrationOn(0);
                                      blocSetting.vibrationOn.add(0);
                                    }
                                  },
                                );
                              }else{
                                return Container();
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 60,
                    child: Row(
                      children: <Widget>[
                        SpaceBox(width: 20,),
                        Text("接近判定距離"),
                        SpaceBox(width: 20,),
                        Container(
                          height: 60,
                          width: 120,
                          child: Row(children: <Widget>[
                            StreamBuilder(
                              stream: blocSetting.onCloseDistanceMeter,
                              builder: (context, snapshot){
                                if(snapshot.hasData){
                                  return NumberPicker.integer(
                                      initialValue: snapshot.data+1,
                                      minValue: 0,
                                      maxValue: 100,
                                      listViewWidth: 40,
                                      highlightSelectedValue: false,
                                      onChanged: (meter){
                                        blocSetting.setTempCloseDistanceMeter(meter-1);
                                      }
                                  );
                                }else{
                                  return Container();
                                }
                              },
                            ),
                            Text("[m]")
                          ],),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(),
            ExpandablePanel(
              header: Center(child: Text("履歴保存設定")),
              expanded: Column(
                children: <Widget>[
                  Container(
                    height: 60,
                    child: Row(
                      children: <Widget>[
                        SpaceBox(width: 20,),
                        Text("移動履歴保存"),
                        SpaceBox(width: 20,),
                        Container(
                          height: 60,
                          width: 60,
                          child: StreamBuilder(
                            stream: blocSetting.onLoggingOn,
                            builder: (context,snapshot){
                              print("data:"+snapshot.data.toString());
                              if(snapshot.hasData) {
                                bool loggingOn = false;
                                if(snapshot.data == 1){
                                  loggingOn = true;
                                }
                                return Switch(
                                  value: loggingOn,
                                  onChanged: (bool){
                                    if(bool){
                                      blocSetting.setTempLoggingOn(1);
                                      blocSetting.loggingOn.add(1);
                                    }else{
                                      blocSetting.setTempLoggingOn(0);
                                      blocSetting.loggingOn.add(0);
                                    }
                                  },
                                );
                              }else{
                                return Container();
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 60,
                    child: Row(
                      children: <Widget>[
                        SpaceBox(width: 20,),
                        Text("記録開始時刻"),
                        SpaceBox(width: 20,),
                        Container(
                          height: 60,
                          width: 120,
                          child: Row(children: <Widget>[
                            StreamBuilder(
                              stream: blocSetting.onStartHour,
                              builder: (context, snapshot){
                                if(snapshot.hasData){
                                  return NumberPicker.integer(
                                      initialValue: snapshot.data+1,
                                      minValue: 0,
                                      maxValue: 23,
                                      listViewWidth: 40,
                                      highlightSelectedValue: false,
                                      onChanged: (hour){
                                        print("start hour :$hour");
                                        blocSetting.setTempStartHour(hour - 1);
                                      }
                                  );
                                }else{
                                  return Container();
                                }
                              },
                            ),
                            Text(":"),
                            StreamBuilder(
                              stream: blocSetting.onStartMinute,
                              builder: (context, snapshot){
                                if(snapshot.hasData){
                                  return NumberPicker.integer(
                                      initialValue: snapshot.data+1,
                                      minValue: 0,
                                      maxValue: 59,
                                      listViewWidth: 40,
                                      highlightSelectedValue: false,
                                      onChanged: (minute){
                                        blocSetting.setTempStartMinute(minute - 1);
                                      }
                                  );
                                }else{
                                  return Container();
                                }
                              },
                            ),
                          ],),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 60,
                    child: Row(
                      children: <Widget>[
                        SpaceBox(width: 20,),
                        Text("記録終了時刻"),
                        SpaceBox(width: 20,),
                        Container(
                          height: 60,
                          width: 120,
                          child: Row(children: <Widget>[

                            StreamBuilder(
                              stream: blocSetting.onEndHour,
                              builder: (context, snapshot){
                                if(snapshot.hasData){
                                  return NumberPicker.integer(
                                      initialValue: snapshot.data+1,
                                      minValue: 0,
                                      maxValue: 23,
                                      listViewWidth: 40,
                                      highlightSelectedValue: false,
                                      onChanged: (hour){
                                        blocSetting.setTempEndHour(hour - 1);
                                      }
                                  );
                                }else{
                                  return Container();
                                }
                              },
                            ),
                            Text(":"),
                            StreamBuilder(
                              stream: blocSetting.onEndMinute,
                              builder: (context, snapshot){
                                if(snapshot.hasData){
                                  return NumberPicker.integer(
                                      initialValue: snapshot.data+1,
                                      minValue: 0,
                                      maxValue: 59,
                                      listViewWidth: 40,
                                      highlightSelectedValue: false,
                                      onChanged: (minute){
                                        blocSetting.setTempEndMinute(minute - 1);
                                      }
                                  );
                                }else{
                                  return Container();
                                }

                              },
                            ),

                          ],),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 60,
                    child: Row(
                      children: <Widget>[
                        SpaceBox(width: 20,),
                        Text("昼休み開始時刻"),
                        SpaceBox(width: 20,),
                        Container(
                          height: 60,
                          width: 120,
                          child: Row(children: <Widget>[

                            StreamBuilder(
                              stream: blocSetting.onStartLunchHour,
                              builder: (context, snapshot){
                                if(snapshot.hasData){
                                  return NumberPicker.integer(
                                      initialValue: snapshot.data+1,
                                      minValue: 0,
                                      maxValue: 23,
                                      listViewWidth: 40,
                                      highlightSelectedValue: false,
                                      onChanged: (hour){
                                        blocSetting.setTempStartLunchHour(hour - 1);
                                      }
                                  );
                                }else{
                                  return Container();
                                }

                              },
                            ),
                            Text(":"),
                            StreamBuilder(
                              stream: blocSetting.onStartLunchMinute,
                              builder: (context, snapshot){
                                if(snapshot.hasData){
                                  return NumberPicker.integer(
                                      initialValue: snapshot.data+1,
                                      minValue: 0,
                                      maxValue: 59,
                                      listViewWidth: 40,
                                      highlightSelectedValue: false,
                                      onChanged: (minute){
                                        blocSetting.setTempStartLunchMinute(minute - 1);
                                      }
                                  );
                                }else{
                                  return Container();
                                }
                              },
                            ),
                          ],),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 60,
                    child: Row(
                      children: <Widget>[
                        SpaceBox(width: 20,),
                        Text("昼休み終了時刻"),
                        SpaceBox(width: 20,),
                        Container(
                          height: 60,
                          width: 120,
                          child: Row(children: <Widget>[

                            StreamBuilder(
                              stream: blocSetting.onEndLunchHour,
                              builder: (context, snapshot){
                                if(snapshot.hasData){
                                  return NumberPicker.integer(
                                      initialValue: snapshot.data+1,
                                      minValue: 0,
                                      maxValue: 23,
                                      listViewWidth: 40,
                                      highlightSelectedValue: false,
                                      onChanged: (hour){
                                        blocSetting.setTempEndLunchHour(hour - 1);
                                      }
                                  );
                                }else{
                                  return Container();
                                }

                              },
                            ),
                            Text(":"),
                            StreamBuilder(
                              stream: blocSetting.onEndLunchMinute,
                              builder: (context, snapshot){
                                if(snapshot.hasData){
                                  return NumberPicker.integer(
                                      initialValue: snapshot.data+1,
                                      minValue: 0,
                                      maxValue: 59,
                                      listViewWidth: 40,
                                      highlightSelectedValue: false,
                                      onChanged: (minute){
                                        blocSetting.setTempEndLunchMinute(minute - 1);
                                      }
                                  );
                                }else{
                                  return Container();
                                }
                              },
                            ),
                          ],),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}