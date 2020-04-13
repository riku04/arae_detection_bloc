import 'dart:async';
import 'dart:io';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter_map_app/src/models/log_data.dart';
import 'package:flutter_map_app/src/utilities/helper.dart';
import 'package:latlong/latlong.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class ReadLogBloc extends Bloc{

  String path;
  List<int> sizes = List();

  final _logListController = StreamController<List<List<String>>>.broadcast();
  Sink<List<List<String>>> get logList => _logListController.sink;
  Stream<List<List<String>>> get onLogList => _logListController.stream;

  Future<void> updateLogList() async{
    Directory directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = directory.listSync();

    List<List<String>> fileList = List();
    List<String> nameList = List();
    List<int> sizes = List();

    files.forEach((file) {
      if(file.path.contains(".csv")) {
        nameList.add(file.path.split("/")[file.path.split("/").length-1]);
        print(file.path);
      }
    });
    
    nameList.sort((a,b){
      return b.compareTo(a);
    });

    await Future.forEach(nameList, (name)async{
      int s = await getFileSizeKbByName(name);
      s = s~/1024;
      sizes.add(s);
    });

    for(int i = 0; i<= nameList.length-1; i++){
      fileList.add([nameList[i],sizes[i].toString()]);
    }

    logList.add(fileList);

    return;
  }

  Future<void> openOnAnotherApp(String filename) async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path +"/"+ filename;
    OpenFile.open(path);
    return;
  }


  Future<LogData> readLogDataByName(String filename) async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path +"/"+ filename;
    File file = File(path);

    LogData logData = LogData();
    //List<List<LatLng>> areas = List();

    List<String> lines = List();
    lines = await file.readAsLines();

    logData.distance = int.parse(lines[1]);

    for(int areaCnt=3; areaCnt<=lines.length-1; areaCnt++){
      if(lines[areaCnt]!="Data,Time,Latitude[deg.],Longitude[deg.],Status") {
        print(lines[areaCnt]);
        //areas.add(Helper.stringToPoints(lines[areaCnt]));
        logData.areas.add(Helper.stringToPoints(lines[areaCnt]));
      }else{
        for(int logCnt = areaCnt+1; logCnt <= lines.length-1; logCnt++){
          print(lines[logCnt]);

          //  2020/3/5,16:51:43,35.707378991460956,139.76797091232208,1

          List<String> split = lines[logCnt].split(",");
          String date = split[0];
          String time = split[1];

          int year = int.parse(date.split("/")[0]);
          int month = int.parse(date.split("/")[1]);
          int day = int.parse(date.split("/")[2]);

          int hour = int.parse(time.split(":")[0]);
          int min = int.parse(time.split(":")[1]);
          int sec = int.parse(time.split(":")[2]);

          double latitude = double.parse(split[2]);
          double longitude = double.parse(split[3]);

          int status = int.parse(split[4]);

          DateTime dateTime = DateTime(year,month,day,hour,min,sec);

          logData.datePoints.add(DatePoint(dateTime,LatLng(latitude,longitude),status));
          //logs.add(LogData(dateTime,LatLng(latitude,longitude)));

        }
        break;
      }
    }
    return logData;
  }

  Future<int> getFileSizeKbByName(String filename)async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path +"/"+ filename;
    File file = File(path);
    return await file.length();
  }

  Future<void> removeLogByName(String filename) async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path +"/"+ filename;
    Directory del = Directory(path);
    print(del.path);
    await del.delete(recursive: true);
    updateLogList();
    return;
  }

  ReadLogBloc(){
    updateLogList();
    onLogList.listen((_){
    });
  }

  @override
  void dispose() {
    _logListController.close();
  }
}