
import 'package:bloc_provider/bloc_provider.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    final blocSetting = BlocProvider.of<SettingBloc>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("SETTING"),
        actions: <Widget>[
          FlatButton(
            child: Text("保存",style: TextStyle(color: Colors.white),),
            onPressed: (){
              print("setting save pressed");
              blocSetting.save();
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
                            builder: (context,userIdSnapshot){
                              print("data:"+userIdSnapshot.data.toString());
                              if(userIdSnapshot.hasData) {
                                return TextFormField(
                                  initialValue: userIdSnapshot.data,
                                  onChanged: (value){
                                    print(value);
                                    blocSetting.settings[UserSettings.USER_ID] = value;
                                    blocSetting.userSettings.userId = value;
                                    print(blocSetting.settings[UserSettings.USER_ID]);
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
                                    blocSetting.settings.update(UserSettings.GROUP_ID, (value) => string);
                                    blocSetting.userSettings.groupId = string;
                                    print(blocSetting.settings[UserSettings.GROUP_ID]);

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
                                      //blocSetting.admin.add(1);
                                      blocSetting.settings.update(UserSettings.ADMIN, (value) => 1);
                                      blocSetting.userSettings.admin = 1;
                                    }else{
                                      //blocSetting.admin.add(0);
                                      blocSetting.settings.update(UserSettings.ADMIN, (value) => 0);
                                      blocSetting.userSettings.admin = 0;
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
                                      //blocSetting.enterAlertOn.add(1);
                                      blocSetting.settings.update(UserSettings.ENTER_ALERT_ON, (value) => 1);
                                      blocSetting.userSettings.enterAlertOn = 1;
                                    }else{
                                      //blocSetting.enterAlertOn.add(0);
                                      blocSetting.settings.update(UserSettings.ENTER_ALERT_ON, (value) => 0);
                                      blocSetting.userSettings.enterAlertOn = 0;
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
                                      //blocSetting.closeAlertOn.add(1);
                                      blocSetting.settings.update(UserSettings.CLOSE_ALERT_ON, (value) => 1);
                                      blocSetting.userSettings.closeAlertOn = 1;
                                    }else{
                                      //blocSetting.closeAlertOn.add(0);
                                      blocSetting.settings.update(UserSettings.CLOSE_ALERT_ON, (value) => 0);
                                      blocSetting.userSettings.closeAlertOn = 0;
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
                                      blocSetting.settings.update(UserSettings.VIBRATION_ON, (value) => 1);
                                      blocSetting.userSettings.vibrationOn = 1;
                                    }else{
                                      blocSetting.settings.update(UserSettings.VIBRATION_ON, (value) => 0);
                                      blocSetting.userSettings.vibrationOn = 0;
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
                                        blocSetting.settings.update(UserSettings.CLOSE_DISTANCE_METER, (value) => meter-1);
                                        blocSetting.userSettings.closeDistanceMeter = meter-1;
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
                                      blocSetting.settings.update(UserSettings.LOGGING_ON, (value) => 1);
                                      blocSetting.userSettings.loggingOn = 1;
                                    }else{
                                      blocSetting.settings.update(UserSettings.LOGGING_ON, (value) => 0);
                                      blocSetting.userSettings.loggingOn = 0;
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
                                        blocSetting.settings.update(UserSettings.START_HOUR, (value) => hour-1);
                                        blocSetting.userSettings.startHour = hour -1;
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
                                        blocSetting.settings.update(UserSettings.START_MINUTE, (value) => minute-1);
                                        blocSetting.userSettings.startMinute = minute - 1;
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
                                        blocSetting.settings.update(UserSettings.END_HOUR, (value) => hour-1);
                                        blocSetting.userSettings.endHour = hour - 1;
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
                                        blocSetting.settings.update(UserSettings.END_MINUTE, (value) => minute-1);
                                        blocSetting.userSettings.endMinute = minute - 1;
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
                                        blocSetting.settings.update(UserSettings.START_LUNCH_HOUR, (value) => hour-1);
                                        blocSetting.userSettings.startLunchHour = hour - 1;
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
                                        blocSetting.settings.update(UserSettings.START_LUNCH_MINUTE, (value) => minute-1);
                                        blocSetting.userSettings.startLunchMinute = minute - 1;
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
                                        blocSetting.settings.update(UserSettings.END_LUNCH_HOUR, (value) => hour-1);
                                        blocSetting.userSettings.endLunchHour = hour - 1;
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
                                        blocSetting.settings.update(UserSettings.END_LUNCH_MINUTE, (value) => minute-1);
                                        blocSetting.userSettings.endLunchMinute = minute - 1;
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