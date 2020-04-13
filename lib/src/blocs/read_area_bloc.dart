import 'dart:async';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter_map_app/src/repository/area_repository.dart';

class ReadAreaBloc extends Bloc{

  final _areaListController = StreamController<List<String>>();
  Sink<List<String>> get areaList => _areaListController.sink;
  Stream<List<String>> get onAreaList => _areaListController.stream;

  void updateAreaList(){
    AreaRepository().getTableList().then((list){

      if(list.contains("android_metadata")){
        list.remove("android_metadata");
      }

      if(list.contains("sqlite_sequence")){
        list.remove("sqlite_sequence");
      }

      areaList.add(list);
      print("area name list updated");
    });
  }

  ReadAreaBloc(){
    updateAreaList();
  }

  @override
  void dispose() {
    _areaListController.close();
  }
}