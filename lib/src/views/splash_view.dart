import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_app/src/app.dart';
import 'package:flutter_map_app/src/resources/constants.dart';
import 'package:splashscreen/splashscreen.dart';

class SplashView extends StatefulWidget {
  @override
  _SplashViewState createState() => new _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  Widget build(BuildContext context) {
    if(Constants.SHOW_SPLASH == true) {
      return new MaterialApp(home: SplashScreen(
          seconds: Constants.SPLASH_TIME_IN_SEC,
          navigateAfterSeconds: new App(),
          title:  Text('進入検知アプリケーション',
            style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0
            ),),
          image:  Image.asset("images/tori.png",height: 100,width: 100,),
          backgroundColor: Colors.white,
          styleTextUnderTheLoader: new TextStyle(),
          photoSize: 100.0,
          onClick: () => print("Splash Image Clicked"),
          loaderColor: Colors.blue
      ),);
    }else{
      return MaterialApp(home:App());
    }
  }
}