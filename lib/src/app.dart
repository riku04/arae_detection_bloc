import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_app/src/blocs/ble_central_bloc.dart';
import 'package:flutter_map_app/src/blocs/map_bloc.dart';
import 'package:flutter_map_app/src/blocs/read_area_bloc.dart';
import 'package:flutter_map_app/src/blocs/read_log_bloc.dart';
import 'package:flutter_map_app/src/blocs/setting_bloc.dart';
import 'package:flutter_map_app/src/repository/area_repository.dart';
import 'package:flutter_map_app/src/repository/user_settings_repository.dart';
import 'package:flutter_map_app/src/views/ble_central_screen.dart';
import 'package:flutter_map_app/src/views/drawer.dart';
import 'package:flutter_map_app/src/views/map_screen.dart';
import 'package:flutter_map_app/src/views/read_area_screen.dart';
import 'package:flutter_map_app/src/views/read_log_screen.dart';
import 'package:flutter_map_app/src/views/setting_screen.dart';
import 'package:flutter_map_app/src/views/splash_view.dart';

class App extends StatelessWidget {
  @override
  build(BuildContext context) {
    AreaRepository areaRepository = AreaRepository();
    UserSettingsRepository userSettingsRepository = UserSettingsRepository();
    return BlocProvider<MapBloc>(
      creator: (context, _bag) => MapBloc(context,areaRepository,userSettingsRepository),
      child: MaterialApp(
        home: SafeArea(
          child: Scaffold(
            body: MapScreen(),
            drawer: MainDrawer(),
          ),
        ),
        routes: <String, WidgetBuilder>{
          '/splash-screen': (BuildContext context) => SplashView(),
          '/map-screen': (BuildContext context) => MapScreen(),
          '/read-area-screen': (BuildContext context) =>
              BlocProvider<ReadAreaBloc>(
                creator: (context, _bag) => ReadAreaBloc(),
                child: ReadAreaScreen(),
              ),
          '/ble-central-screen': (BuildContext context) =>
              BlocProvider<BleCentralBloc>(
                creator: (context, _bag) => BleCentralBloc(context),
                child: BleCentralScreen(),
              ),
          '/setting-screen':(BuildContext context) =>
              BlocProvider<SettingBloc>(
                creator: (context, _bag) => SettingBloc(userSettingsRepository),
                child: SettingScreen(),
              ),
          '/read-log-screen': (BuildContext context) =>
              BlocProvider<ReadLogBloc>(
                creator: (context, _bag) => ReadLogBloc(),
                child: ReadLogScreen(),
              ),
        },
      ),
    );
  }
}
