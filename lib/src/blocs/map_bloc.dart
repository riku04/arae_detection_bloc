import 'dart:async';

import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_app/src/models/area.dart';
import 'package:flutter_map_app/src/repository/area_repository.dart';
import 'package:latlong/latlong.dart';


class MapBloc extends Bloc{
  List<Marker> _draftMarkers; //下書きポリゴンのマーカー
  List<Polygon> _draftPolygons; //PolygonLayerOptionsに下書きポリゴンを渡すためのリスト、要素数が1以上になることはない
  List<Polygon> _polygons;      //こちらは禁止領域のポリゴン、複数になる
  List<Polygon> _expandedPolygons;  //接近領域
  List<Polygon> _moreExpandedPolygons;  //準接近領域

  List<LayerOptions> layers; //画面更新はこの変数をStreamに流すことで行う
  TileLayerOptions _tileLayer;  //地図タイルのレイヤ
  MarkerLayerOptions _draftMarkerLayer; //下書きマーカーのレイヤ
  PolygonLayerOptions _draftPolygonLayer; //下書きポリゴンのレイヤ
  PolygonLayerOptions _polygonLayer;  //禁止領域ポリゴンのレイヤ
  PolygonLayerOptions _expandedPolygonLayer;  //接近領域ポリゴンのレイヤ
  PolygonLayerOptions _moreExpandedPolygonLayer;  //準接近領域ポリゴンのレイヤ

  final StreamController<MapOptions> _optionsController = StreamController<MapOptions>();
  Sink<MapOptions> get initOptions => _optionsController.sink;
  Stream<MapOptions> get onInitOptions => _optionsController.stream;

  final _addPointController = StreamController<LatLng>.broadcast();
  Sink<LatLng> get addPoint => _addPointController.sink;
  Stream<LatLng> get onAddPoint => _addPointController.stream;

  final _layersController = StreamController<List<LayerOptions>>();
  Sink<List<LayerOptions>> get setLayers => _layersController.sink;
  Stream<List<LayerOptions>> get onLayersChanged => _layersController.stream;

  void initMapOptions(){
    MapOptions _mapOptions = new MapOptions(
        center: new LatLng(35.691075, 139.767828),
        zoom: 13.0,
        onTap: (_latLng) {

        });
    initOptions.add(_mapOptions);
  }


  void initLayers(){
    layers = List();
    _tileLayer = TileLayerOptions(
        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        subdomains: ['a', 'b', 'c']
    );
    _draftMarkerLayer = MarkerLayerOptions(
      markers: _draftMarkers
    );
    _draftPolygonLayer = PolygonLayerOptions(
      polygons: _draftPolygons
    );
    _polygonLayer = PolygonLayerOptions(
      polygons: _polygons
    );
    _expandedPolygonLayer = PolygonLayerOptions(
      polygons: _expandedPolygons
    );
    _moreExpandedPolygonLayer = PolygonLayerOptions(
      polygons: _moreExpandedPolygons
    );
    layers.add(_tileLayer);
    layers.add(_draftMarkerLayer);
    layers.add(_draftPolygonLayer);
    layers.add(_polygonLayer);
    layers.add(_expandedPolygonLayer);
    layers.add(_moreExpandedPolygonLayer);
    _layersController.add(layers);
  }

  void createDraftPolygon(List<Marker> markers){
    List<LatLng> points = new List();
    markers.forEach((marker){
      points.add(marker.point);
    });

    _draftPolygons.clear();
    _draftPolygons.add(new Polygon(
      points: points,
      color: Color(Colors.grey.value-0x20000000),
      borderColor: Color(Colors.grey.value-0x20000000),
      borderStrokeWidth: 1.0,
    ));

    setLayers.add(layers);
  }

  void createPolygon(){
    if(_draftPolygons.isEmpty){
      return;
    }
    Polygon polygon = _draftPolygons[0];
    _polygons.add(new Polygon(
      points: polygon.points,
      color: Color(Colors.red.value-0x20000000),
      borderColor: Color(Colors.red.value-0x00000000),
      borderStrokeWidth: 1.0
    ));
    print("determined");
    setLayers.add(layers);

    _draftMarkers.clear();
    _draftPolygons.clear();

    Area area = Area();
    area.areaPointsStr = Area.pointsToString(polygon.points);
    AreaRepository().addPoints("area0", area);  //tableName,Area
  }

  void readSavedArea() async{
    List<List<LatLng>> areaList = List();
    areaList = await AreaRepository().getAreaList("area0");

    _polygons.clear();
    areaList.forEach((points){
      Polygon polygon = new Polygon(
          points: points,
          color: Color(Colors.red.value-0x20000000),
          borderColor: Color(Colors.red.value-0x00000000),
          borderStrokeWidth: 1.0
      );
      _polygons.add(polygon);
    });
    setLayers.add(layers);
  }

  MapBloc(){

    _draftMarkers = new List();
    _draftPolygons = new List();
    _polygons = new List();
    _expandedPolygons = new List();
    _moreExpandedPolygons = new List();

    onAddPoint.listen((point){
      Marker _marker = new Marker(
        width: 40.0,
        height: 80.0,
        point: point,
        builder: (ctx) =>
        new Container(
          child: new FlutterLogo(),
        ),
      );

      if(_draftMarkers.length>=1){
        if((_draftMarkers[_draftMarkers.length-1].point.latitude==point.latitude) &&
            (_draftMarkers[_draftMarkers.length-1].point.longitude==point.longitude)){
          return; //同じ座標に連続してマーカーは置けない
        }
      }
        _draftMarkers.add(_marker);
        setLayers.add(layers);
        print(point);
        if(_draftMarkers.length>2) {
           createDraftPolygon(_draftMarkers);
        }
    });

    readSavedArea();
  }
  @override
  void dispose() {
    _optionsController.close();
    _addPointController.close();
  }

}