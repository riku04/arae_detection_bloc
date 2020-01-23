import 'dart:io';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_app/src/models/user_settings.dart';
import 'package:flutter_map_app/src/repository/user_settings_repository.dart';
import 'package:flutter_map_app/src/utilities/helper.dart';
import 'package:latlong/latlong.dart';
import 'package:path_provider/path_provider.dart';

class Logger{
  String path;
  List<Polygon> polygons;

  Logger(List<Polygon> polygons){
    initLogger(polygons);
  }

  Future<void> initLogger(List<Polygon> polygons) async{
    final directory = await getApplicationDocumentsDirectory();
    final DateTime now = DateTime.now();
    final filename = "${now.hour}:${now.minute}:${now.second}";
    this.path = directory.path+"/"+filename+".csv";
    this.polygons = polygons;
    return;
  }

  Future<void> addLog(DateTime dateTime,LatLng point,int status) async{
    final file = File(path);
    bool exists = await file.exists();

    String line = "";
    line +=  "${dateTime.year}/${dateTime.month}/${dateTime.day},";
    line += "${dateTime.hour}:${dateTime.minute}:${dateTime.second},";
    line += "${point.latitude},";
    line += "${point.longitude},";
    line += "$status";

    if(!exists){
      print("[$path] doesn't exist, initializing...");
      print("this log contains [${polygons.length}] polygons");
      Map<String, dynamic> us = await UserSettingsRepository().getValues();
      await file.writeAsString("Approach Distance[m]"+"\n",mode: FileMode.append,flush: true);
      await file.writeAsString("${us[UserSettings.CLOSE_DISTANCE_METER]}"+"\n",mode: FileMode.append,flush: true);
      await file.writeAsString("Area Coordinates[deg.]"+"\n",mode: FileMode.append,flush: true);
      if(polygons!=null&&polygons.isNotEmpty) {
        polygons.forEach((polygon) async {
          await file.writeAsString(Helper.pointsToString(polygon.points)+"\n",mode: FileMode.append,flush: true);
        });
      }
      await file.writeAsString("Data,Time,Latitude[deg.],Longitude[deg.],Status"+"\n",mode: FileMode.append,flush: true);
    }

    Stopwatch sw = Stopwatch();
    sw.start();
    await file.writeAsString(line + "\n", mode: FileMode.append,flush: true);
    sw.stop();
    print("write line takes [${sw.elapsedMicroseconds}] us");
    return;
  }

  Future<List<String>> readLines() async{
    List<String> lines = List();
    final file = File(path);
    Stopwatch sw = Stopwatch();
    sw.start();
    lines = await file.readAsLines();
    sw.stop();
    print("read lines takes [${sw.elapsedMicroseconds}] us");
    return lines;
  }

}