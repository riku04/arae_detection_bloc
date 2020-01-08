
import 'dart:async';

import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter_map_app/src/repository/area_repository.dart';

class ReadAreaBloc extends Bloc{

  final _areaListController = StreamController<List<String>>();
  Sink<List<String>> get areaList => _areaListController.sink;
  Stream<List<String>> get onAreaList => _areaListController.stream;

  void updateAreaList(){
    AreaRepository().getTableList().then((list){
      areaList.add(list);
      print("area name list updated");
    });
  }

  ReadAreaBloc(){
    updateAreaList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _areaListController.close();
  }
}