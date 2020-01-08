
import 'dart:async';

import 'package:flutter_map_app/src/database/area_database_provider.dart';
import 'package:flutter_map_app/src/models/area.dart';
import 'package:latlong/latlong.dart';
import 'package:sqflite/sqflite.dart';

class AreaRepository{
  Future<void> createNewTable(String tableName) async{
    final AreaDatabaseProvider provider = AreaDatabaseProvider();
    final Database database = await provider.database;
    return await database.execute(
      """
        CREATE TABLE $tableName(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          points TEXT
        )
      """
    ).then((_){
      getTableList().then((list){
        print(list);
      });
    });
  }

  Future<void> addDataToTable(String tableName, Area area) async{ //areaNameのテーブルにポリゴンの頂点座標を追加する
      final AreaDatabaseProvider provider = AreaDatabaseProvider();
      final Database database = await provider.database;
      print("added to database:"+area.toJson().toString());
      return await database.insert(tableName, area.toJson());
  }

  Future<List<String>> getTableList() async{
    final AreaDatabaseProvider provider = AreaDatabaseProvider();
    final Database database = await provider.database;
    return await database.rawQuery("SELECT name FROM sqlite_master WHERE type='table'").then((list){
      List<String> tables = List();
      list.forEach((map){
        tables.add(map["name"]);
      });
      return tables;
    });
  }

  Future<List<List<LatLng>>> getPointsListFromTableName(String tableName) async{
    final AreaDatabaseProvider provider = AreaDatabaseProvider();
    final Database database = await provider.database;
    return await database.query(tableName).then((maps){
      if(maps.length > 0) {
        List<String> strList = List();
        maps.forEach((map) {
          strList.add(map["points"]);
          print(map["points"]);
        });

        List<List<LatLng>> areaList = List();
        strList.forEach((str){
          List<LatLng> points = List();
          points = Area.stringToPolygon(str);
          areaList.add(points);
        });

        return areaList;
      } else {
        print("table has no data");
        return List();
      }
    });
  }

  Future<void> removeTable(String tableName) async{
    final AreaDatabaseProvider provider = AreaDatabaseProvider();
    final Database database = await provider.database;
    database.rawQuery("DROP TABLE IF EXISTS $tableName").then((_){
      return;
    });
  }

}