import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_app/src/blocs/setting_bloc.dart';
import 'package:flutter_map_app/src/widgets/space_box.dart';

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
        appBar: AppBar(title: Text("SETTING"),),
        body:ListView(
          children: <Widget>[
            SpaceBox(height: 20,),
            Container(
              width: 50,
              height: 30,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SpaceBox(
                    height: 20,
                    width: 20,
                  ),
                  Text("admin"),
                  Switch(
                    value: false,
                    onChanged: (bool){

                  },)
                ],
              ),
            )
          ],
        ),

      ),
    );
  }
}