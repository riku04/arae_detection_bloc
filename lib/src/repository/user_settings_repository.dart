import 'package:flutter_map_app/src/database/user_settings_database_provder.dart';
import 'package:flutter_map_app/src/models/user_settings.dart';
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

  Future<List<String>> getColumnList(String tableName) async {
    final UserSettingsDatabaseProvider provider =
        UserSettingsDatabaseProvider();
    final Database database = await provider.database;
    return await database.rawQuery("SELECT * FROM '$tableName'").then((list) {
      print("getCulmnList...");
      print(list.length);
      List<String> column = List();
      list.forEach((map) {
        map.keys.forEach((key) {
          print(key + ":" + map[key].toString());
        });
      });
      return column;
    });
  }

  Future<void> addData(String tableName) async {
    final UserSettingsDatabaseProvider provider =
        UserSettingsDatabaseProvider();
    final Database database = await provider.database;
    UserSettings userSettings = UserSettings();
    database.insert(tableName, userSettings.toJson()).then((_) {
      print("data added");
      return;
    });
  }

  Future<void> getData(String tableName) async {
    final UserSettingsDatabaseProvider provider =
        UserSettingsDatabaseProvider();
    final Database database = await provider.database;
    await database.query(tableName).then((maps) {
      maps.forEach((value) {
        print(value['USER_ID']);
      });
    });
  }
}
