
import 'dart:async';
import 'dart:io';

import 'package:flutter_map_app/src/database/area_database_provider.dart';
import 'package:flutter_map_app/src/models/area.dart';
import 'package:latlong/latlong.dart';
import 'package:sqflite/sqflite.dart';

class AreaRepository{
  Future<int> addPoints(String areaName, Area area) async{ //areaNameのテーブルにポリゴンの頂点座標を追加する
      final AreaDatabaseProvider provider = AreaDatabaseProvider(areaName);
      final Database database = await provider.database;
      print("added:"+area.toJson().toString());
      return await database.insert(provider.tableName, area.toJson());
  }

  Future<List<List<LatLng>>> getAreaList(String areaName) async{
    final AreaDatabaseProvider provider = AreaDatabaseProvider(areaName);
    final Database database = await provider.database;
    List<Map> maps = await database.query(areaName);

    if(maps.length > 0){

      List<String> strList = List();
      maps.forEach((map){
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
    }
  }

  void removeAllDatabase() async{
    String path = await getDatabasesPath();
    List files = Directory(path).listSync();
    files.forEach((file){
      if((file.path.toString().contains("area"))){
        print("removed:"+file.path.toString());
        Directory(file.path.toString()).deleteSync(recursive: true);
      }
    });
  }
}