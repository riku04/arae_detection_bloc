import 'dart:io';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_app/src/models/user_settings.dart';
import 'package:flutter_map_app/src/repository/user_settings_repository.dart';
import 'package:flutter_map_app/src/utilities/helper.dart';
import 'package:latlong/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class Logger{
  String path="";
  List<Polygon> polygons;
  Map<String,dynamic> parameter;

  Future<void> initLogger(List<Polygon> polygons,Map<String,dynamic> parameter) async{
//    final directory = await getApplicationDocumentsDirectory();
//    final DateTime now = DateTime.now();
//    DateFormat formatter =  DateFormat("yyyyMMddhhmmss");
//    String formatted = formatter.format(now);
//    var filename = formatted;
//    this.path = directory.path+"/"+filename+".csv";

    this.path = "";
    this.polygons = polygons;
    this.parameter = parameter;
    print("logger status \npolygons:[${polygons.length}]\nUserSettings[${parameter.toString()}]");

    return;
  }

  Future<void> addLog(DateTime dateTime,LatLng point,int status) async{

    if(path==""){
      final directory = await getApplicationDocumentsDirectory();
      final DateTime now = DateTime.now();
      DateFormat formatter =  DateFormat("yyyyMMddHHmmss");
      String formatted = formatter.format(now);
      var filename = formatted;
      this.path = directory.path+"/"+filename+".csv";
    }

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
      Map<String, dynamic> us = await UserSettingsRepository().getTableData();
      await file.writeAsString("Approach Distance[m]"+"\n",mode: FileMode.append,flush: true);
      await file.writeAsString("${us[UserSettings.CLOSE_DISTANCE_METER]}"+"\n",mode: FileMode.append,flush: true);
      await file.writeAsString("Area Coordinates[deg.]"+"\n",mode: FileMode.append,flush: true);

//      if(polygons.isNotEmpty){
//        Future.forEach(polygons, (polygon) async{
//          String pointsString = Helper.pointsToString(polygon);
//          file.writeAsString(pointsString+"\n",mode: FileMode.append,flush: true);
//        });
//      }
      String pointsString = "";
      if(polygons!=null&&polygons.isNotEmpty){
        polygons.forEach((polygon){
          pointsString += Helper.pointsToString(polygon.points)+"\n";
        });
      }
      await file.writeAsString(pointsString,mode: FileMode.append,flush: true);
      await file.writeAsString("Data,Time,Latitude[deg.],Longitude[deg.],Status"+"\n",mode: FileMode.append,flush: true);
    }

    Stopwatch sw = Stopwatch();
    sw.start();
    await file.writeAsString(line + "\n", mode: FileMode.append,flush: true);
    print(line);
    sw.stop();
    //print("write line takes [${sw.elapsedMicroseconds}] us");
    return;
  }

  Future<List<String>> readLines() async{
    List<String> lines = List();
    final file = File(path);
    Stopwatch sw = Stopwatch();
    sw.start();
    lines = await file.readAsLines();
    sw.stop();
    //print("read lines takes [${sw.elapsedMicroseconds}] us");
    return lines;
  }

}