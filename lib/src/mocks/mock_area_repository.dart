import 'package:flutter_map_app/src/models/area.dart';
import 'package:flutter_map_app/src/repository/area_repository.dart';
import 'package:latlong/latlong.dart';

class MockAreaRepository implements AreaRepository{

  @override
  Future<void> createNewTable(String tableName) async{
    print("this function should not be used in mock class");
  }

  @override
  Future<void> addDataToTable(String tableName, Area area) async {
    print("this function should not be used in mock class");
  }

  @override
  Future<List<String>> getTableList() async{
    return [
      "area0",
      "area1",
      "area2",
      "area3",
    ];
  }

  @override
  Future<List<List<LatLng>>> getPointsListFromTableName(String tableName) async {
    return [
      [LatLng(1,1)],
      [LatLng(2,2)],
      [LatLng(3,3)],
      [LatLng(4,4)],
    ];
  }

  @override
  Future<void> removeTable(String tableName) async{
    print("this function should not be used in mock class");
  }

}