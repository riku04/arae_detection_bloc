import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_app/src/blocs/map_bloc.dart';
import 'package:flutter_map_app/src/blocs/read_area_bloc.dart';
import 'package:flutter_map_app/src/views/drawer.dart';
import 'package:flutter_map_app/src/views/map_screen.dart';
import 'package:flutter_map_app/src/views/read_area_screen.dart';
import 'package:flutter_map_app/src/views/splash_screen.dart';

class App extends StatelessWidget {
  @override
  build(BuildContext context) {
    return BlocProvider<MapBloc>(
      creator: (context, _bag) => MapBloc(),
      child: MaterialApp(
        home: SafeArea(
          child: Scaffold(
            body: MapScreen(),
            drawer: MainDrawer(),
          ),
        ),
        routes: <String, WidgetBuilder>{
          '/splash-screen': (BuildContext context) => SplashScreen(),
          '/map-screen': (BuildContext context) => MapScreen(),
          '/read-area-screen': (BuildContext context) =>
              BlocProvider<ReadAreaBloc>(
                creator: (context, _bag) => ReadAreaBloc(),
                child: ReadAreaScreen(),
              ),
        },
      ),
    );
  }
}
