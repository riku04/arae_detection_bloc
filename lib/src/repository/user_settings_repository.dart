import 'package:flutter_map_app/src/database/user_settings_database_provder.dart';
import 'package:flutter_map_app/src/models/user_settings.dart';
import 'package:flutter_map_app/src/resources/constants.dart';
import 'package:sqflite/sqflite.dart';

class UserSettingsRepository {

  Future<List<String>> getTableList() async {
    final UserSettingsDatabaseProvider provider =
        UserSettingsDatabaseProvider();
    final Database database = await provider.database;
    return await database
        .rawQuery("SELECT name FROM sqlite_master WHERE type='table'")
        .then((list) {
      List<String> tables = List();
      list.forEach((map) {
        map.keys.forEach((key) {
          print(map[key]);
          tables.add(map[key]);
        });
      });
      return tables;
    });
  }

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

  Future<Map<String,dynamic>> getValues() async{
    String table = Constants.DEFAULT_USER_SETTING_TABLE;
    final UserSettingsDatabaseProvider provider =
    UserSettingsDatabaseProvider();
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

  Future<bool> setValue(String column, dynamic value) async{
    if(value is String||value is int||value is bool){
      if(value is bool){
        if(value){
          value = 1;
        }else{
          value = 0;
        }
      }
      String table = Constants.DEFAULT_USER_SETTING_TABLE;
      final UserSettingsDatabaseProvider provider =
      UserSettingsDatabaseProvider();
      final Database database = await provider.database;
      await database.rawUpdate("UPDATE $table SET $column = ?", ["$value"])
          .then((_) {
            print("******update user settings******");
          });
    } else {
      print("user setting set value error, invalid Type");
    }
  }

}
