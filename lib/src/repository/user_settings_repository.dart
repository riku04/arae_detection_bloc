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

  Future<List<String>> getColumnList() async {
    final UserSettingsDatabaseProvider provider =
        UserSettingsDatabaseProvider();
    final Database database = await provider.database;
    String table = Constants.DEFAULT_USER_SETTING_TABLE;
    return await database.rawQuery("SELECT * FROM '$table'").then((list) {
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

  Future<dynamic> getValueByColumnName(String column) async {
    final UserSettingsDatabaseProvider provider =
        UserSettingsDatabaseProvider();
    final Database database = await provider.database;
    String table = Constants.DEFAULT_USER_SETTING_TABLE;
    return await getColumnList().then((list) {
      if (list.length == 0) {
        initData().then((_) {
          database.rawQuery("SELECT $column FROM $table").then((list) {
            print("$column:" + list[0][column]);
            return list[0][column];
          });
        });
      } else {
        database.rawQuery("SELECT $column FROM $table").then((list) {
          print("$column:" + list[0][column]);
          return list[0][column];
        });
      }
    });
  }

  Future<void> initData() async {
    final UserSettingsDatabaseProvider provider =
        UserSettingsDatabaseProvider();
    final Database database = await provider.database;
    String table = Constants.DEFAULT_USER_SETTING_TABLE;
    UserSettings userSettings = UserSettings();
    database.insert(table, userSettings.toJson()).then((_) {
      print("init user settings");
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
