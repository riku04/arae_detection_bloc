
import 'dart:async';

import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter_map_app/src/models/user_settings.dart';
import 'package:flutter_map_app/src/repository/user_settings_repository.dart';

class SettingBloc extends Bloc{

  final _adminController = StreamController<bool>();
  Sink<bool> get admin => _adminController.sink;
  Stream<bool> get onAdmin => _adminController.stream;

  final _userIdController = StreamController<String>();
  Sink<String> get userId => _userIdController.sink;
  Stream<String> get onUserId => _userIdController.stream;

  void readCurrentSettings() async{
    Map<String,dynamic> settings = await UserSettingsRepository().getValues();

    userId.add(settings[Parameter.USER_ID]);
    admin.add(settings[UserSettings.ADMIN]);

  }

  SettingBloc(){

    readCurrentSettings();

  }


  @override
  void dispose() {
    _adminController.close();
    _userIdController.close();
  }

}