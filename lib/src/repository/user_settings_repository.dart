import 'package:flutter_map_app/src/database/user_settings_database_provder.dart';
import 'package:flutter_map_app/src/models/user_settings.dart';
import 'package:flutter_map_app/src/resources/constants.dart';
import 'package:sqflite/sqflite.dart';

class UserSettingsRepository {

  Future<void> initData() async {
    final UserSettingsDatabaseProvider provider =
    UserSettingsDatabaseProvider();
    final Database database = await provider.database;
    String table = Constants.DEFAULT_USER_SETTING_TABLE;
    UserSettings userSettings = UserSettings();
    await database.insert(table, userSettings.toJson()).then((_) {
      print("******init user settings******");
      return;
    });
  }

  Future<Map<String,dynamic>> getTableData() async{
    String table = Constants.DEFAULT_USER_SETTING_TABLE;
    final UserSettingsDatabaseProvider provider = UserSettingsDatabaseProvider();
    final Database database = await provider.database;
    List list = await database.rawQuery("SELECT * FROM $table");
    if(list.isEmpty){
      await initData();
      list = await database.rawQuery("SELECT * FROM $table");
      return list[0];
    }else{
      return list[0];
    }
  }



  Future<void> setTableData(UserSettings settings) async{
    final UserSettingsDatabaseProvider provider =
    UserSettingsDatabaseProvider();
    final Database database = await provider.database;
    String table = Constants.DEFAULT_USER_SETTING_TABLE;
    print(settings);
    await database.update(table, settings.toJson());
  }
}
