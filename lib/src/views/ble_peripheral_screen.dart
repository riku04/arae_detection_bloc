import 'package:flutter/material.dart';
import 'package:flutter_map_app/src/blocs/ble_peripheral_bloc.dart';
import 'package:flutter_map_app/src/repository/user_settings_repository.dart';
import 'package:flutter_map_app/src/widgets/space_box.dart';

class BlePeripheralScreen{
  BuildContext context;
  BlePeripheralBloc blePeripheralBloc;

  BlePeripheralScreen(BuildContext context){
    this.context = context;
  }

  void startAdvertiseDialog(){

    blePeripheralBloc = BlePeripheralBloc(context);
    UserSettingsRepository().getTableData().then((settings){
      blePeripheralBloc.startAdvertise("${settings["USER_ID"]},${settings["GROUP_ID"]}");
    });

    Widget progress = Container(width: 1,height: 1,);
    progress = LinearProgressIndicator();
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
                StreamBuilder(
                  stream: blePeripheralBloc.onStatus,
                  builder: (context, statusSnapshot){
                    if(statusSnapshot.hasData){

                      if(statusSnapshot.data=="complete"){
                        Navigator.of(context).pop();
                      }

                      return Center(child: Text(statusSnapshot.data.toString(),style: TextStyle(fontSize: 20.0,color: Colors.lightBlue),),);
                    }else{
                      return SpaceBox(width:1,height:1);
                    }

                  },
                ),
                SpaceBox(height: 10,),
                LinearProgressIndicator(),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: (){
                blePeripheralBloc.stopAdvertise();
                Navigator.pop(context);
                },
            ),
            SpaceBox(width: 5,)
          ],

        );
      }
    );

  }


}