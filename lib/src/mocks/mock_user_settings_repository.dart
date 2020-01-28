import 'package:flutter_map_app/src/models/user_settings.dart';
import 'package:flutter_map_app/src/repository/user_settings_repository.dart';

class MockUserSettingsRepository implements UserSettingsRepository{

  UserSettings _userSettings;

  MockUserSettingsRepository(){
    _userSettings = UserSettings();
  }

  @override
  Future<void> initData() async{
    _userSettings = UserSettings();
    return;
  }

  @override
  Future<Map<String,dynamic>> getTableData() async{
    Map<String, dynamic> map = _userSettings.toJson();
    if(map.isEmpty){
      initData();
      map = _userSettings.toJson();
      return map;
    } else {
      return _userSettings.toJson();
    }
  }

  @override
  Future<void> setTableData(UserSettings settings) async{
    _userSettings = settings;
  }

}