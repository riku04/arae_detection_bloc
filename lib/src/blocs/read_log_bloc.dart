import 'dart:async';
import 'dart:io';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class ReadLogBloc extends Bloc{

  String path;

  final _logListController = StreamController<List<String>>();
  Sink<List<String>> get logList => _logListController.sink;
  Stream<List<String>> get onLogList => _logListController.stream;

  void updateLogList() async{
    Directory directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = directory.listSync();
    List<String> fileList = List();
    files.forEach((file) {
      if(file.path.contains(".csv")) {
        fileList.add(file.path.split("/")[file.path.split("/").length-1]);
        print(file.path);
      }
    });
    logList.add(fileList);
  }

  Future<void> openOnAnotherApp(String filename) async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path +"/"+ filename;
    OpenFile.open(path,type: "text/plain",uti: "public.plauin-text");
    return;
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
  }

  @override
  void dispose() {
    _logListController.close();
  }
}