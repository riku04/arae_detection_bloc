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

  bool isLoggingAllowedTime(DateTime now){
    bool result = false;

    int startHour = parameter[UserSettings.START_HOUR];
    int startMin = parameter[UserSettings.START_MINUTE];
    int startLunchHour = parameter[UserSettings.START_LUNCH_HOUR];
    int startLunchMin = parameter[UserSettings.START_LUNCH_MINUTE];
    int endLunchHour = parameter[UserSettings.END_LUNCH_HOUR];
    int endLunchMin = parameter[UserSettings.END_LUNCH_MINUTE];
    int endHour = parameter[UserSettings.END_HOUR];
    int endMin = parameter[UserSettings.END_MINUTE];

    DateTime startTime = DateTime(now.year,now.month,now.day,startHour,startMin);
    DateTime startLunchTime = DateTime(now.year,now.month,now.day,startLunchHour,startLunchMin);
    DateTime endLunchTime = DateTime(now.year,now.month,now.day,endLunchHour,endLunchMin);
    DateTime endTime = DateTime(now.year,now.month,now.day,endHour,endMin);

//    print("**********");
//    print("now:"+now.toString());
//    print("start:"+startTime.toString());
//    print("start lunch:"+startLunchTime.toString());
//    print("end lunch:"+endLunchTime.toString());
//    print("end:"+endTime.toString());
//    print("**********");

    if((now.isAfter(startTime)&&now.isBefore(startLunchTime))||
        (now.isAfter(endLunchTime)&&now.isBefore(endTime))){
      //print("logging : on");
      result = true;
    }else{
      //print("logging : off");
    }

    return result;
  }

  Future<void> addLog(DateTime dateTime,LatLng point,int status) async{

    if(!isLoggingAllowedTime(dateTime)){
      return;
    }

    if(path==""){
      final directory = await getApplicationDocumentsDirectory();
      final DateTime now = DateTime.now();
      DateFormat formatter =  DateFormat("yyyyMMddHHmmss");
      String formatted = formatter.format(now);
      var filename = parameter[UserSettings.GROUP_ID]+"_"+parameter[UserSettings.USER_ID]+"_"+formatted;
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
    //print(line);
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