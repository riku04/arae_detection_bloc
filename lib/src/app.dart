import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_app/src/blocs/ble_scan_bloc.dart';
import 'package:flutter_map_app/src/blocs/map_bloc.dart';
import 'package:flutter_map_app/src/blocs/read_area_bloc.dart';
import 'package:flutter_map_app/src/blocs/setting_bloc.dart';
import 'package:flutter_map_app/src/repository/area_repository.dart';
import 'package:flutter_map_app/src/repository/user_settings_repository.dart';
import 'package:flutter_map_app/src/views/ble_scan_screen.dart';
import 'package:flutter_map_app/src/views/drawer.dart';
import 'package:flutter_map_app/src/views/map_screen.dart';
import 'package:flutter_map_app/src/views/read_area_screen.dart';
import 'package:flutter_map_app/src/views/setting_screen.dart';
import 'package:flutter_map_app/src/views/splash_screen.dart';

class App extends StatelessWidget {
  @override
  build(BuildContext context) {
    AreaRepository areaRepository = AreaRepository();
    UserSettingsRepository userSettingsRepository = UserSettingsRepository();
    return BlocProvider<MapBloc>(
      creator: (context, _bag) => MapBloc(areaRepository,userSettingsRepository),
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
          '/ble-scan-screen': (BuildContext context) =>
              BlocProvider<BleScanBloc>(
                creator: (context, _bag) => BleScanBloc(),
                child: BleScanScreen(),
              ),
          '/setting-screen':(BuildContext context) =>
              BlocProvider<SettingBloc>(
                creator: (context, _bag) => SettingBloc(userSettingsRepository),
                child: SettingScreen(),
              )
          ,
        },
      ),
    );
  }
}
