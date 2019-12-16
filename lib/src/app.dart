import 'dart:io';

import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_app/src/blocs/map_bloc.dart';
import 'package:flutter_map_app/src/views/map_screen.dart';

class App extends StatelessWidget{

  @override
  build(BuildContext context){
    return MaterialApp(
      home:Scaffold(

        body:BlocProvider<MapBloc>(
          creator: (context,_bag) => MapBloc(),
          child: MapScreen(),
        ),

        drawer: Drawer(
        ),
      )
    );
  }

}