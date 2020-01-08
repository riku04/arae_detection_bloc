import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget{

  @override
  build(BuildContext context){
    return  Scaffold(
      body: Center(
        child: FlatButton(
          child: Text(DateTime.now().toString()),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
