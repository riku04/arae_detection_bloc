import 'dart:async';

import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_app/src/models/area.dart';
import 'package:flutter_map_app/src/repository/area_repository.dart';
import 'package:flutter_map_app/src/resources/constants.dart';
import 'package:latlong/latlong.dart';
import 'package:vibration/vibration.dart';

class MapBloc extends Bloc {
  List<Marker> _draftMarkers; //下書きポリゴンのマーカー
  List<Marker> _logMarkers;
  List<Polygon>
      _draftPolygons; //PolygonLayerOptionsに下書きポリゴンを渡すためのリスト、要素数が1以上になることはない
  List<Polygon> _polygons; //こちらは禁止領域のポリゴン、複数になる
  List<Polygon> _expandedPolygons; //接近領域
  List<Polygon> _moreExpandedPolygons; //準接近領域

  List<LayerOptions> layers; //画面更新はこの変数をStreamに流すことで行う
  TileLayerOptions _tileLayer; //地図タイルのレイヤ
  MarkerLayerOptions _draftMarkerLayer; //下書きマーカーのレイヤ
  MarkerLayerOptions _logMarkerLayer;
  PolygonLayerOptions _draftPolygonLayer; //下書きポリゴンのレイヤ
  PolygonLayerOptions _polygonLayer; //禁止領域ポリゴンのレイヤ
  PolygonLayerOptions _expandedPolygonLayer; //接近領域ポリゴンのレイヤ
  PolygonLayerOptions _moreExpandedPolygonLayer; //準接近領域ポリゴンのレイヤ

  final StreamController<MapOptions> _optionsController =
      StreamController<MapOptions>();
  Sink<MapOptions> get initOptions => _optionsController.sink;
  Stream<MapOptions> get onInitOptions => _optionsController.stream;

  final _addPointController = StreamController<LatLng>.broadcast();
  Sink<LatLng> get addPoint => _addPointController.sink;
  Stream<LatLng> get onAddPoint => _addPointController.stream;

  final _layersController = StreamController<List<LayerOptions>>();
  Sink<List<LayerOptions>> get setLayers => _layersController.sink;
  Stream<List<LayerOptions>> get onLayersChanged => _layersController.stream;

  final _currentLocationController =
      StreamController<LatLng>.broadcast(); //>>isInside,addLog
  Sink<LatLng> get addCurrentLocation => _currentLocationController.sink;
  Stream<LatLng> get onCurrentLocationChanged =>
      _currentLocationController.stream;

  void initMapOptions() {
    MapOptions _mapOptions = new MapOptions(
        center: new LatLng(35.691075, 139.767828),
        zoom: 13.0,
        onTap: (_latLng) {
          addCurrentLocation.add(_latLng);
        });
    initOptions.add(_mapOptions);
  }

  void initLayers() {
    layers = List();
    _tileLayer = TileLayerOptions(
        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        subdomains: ['a', 'b', 'c']);
    _draftMarkerLayer = MarkerLayerOptions(markers: _draftMarkers);
    _logMarkerLayer = MarkerLayerOptions(markers: _logMarkers);
    _draftPolygonLayer = PolygonLayerOptions(polygons: _draftPolygons);
    _polygonLayer = PolygonLayerOptions(polygons: _polygons);
    _expandedPolygonLayer = PolygonLayerOptions(polygons: _expandedPolygons);
    _moreExpandedPolygonLayer =
        PolygonLayerOptions(polygons: _moreExpandedPolygons);
    layers.add(_tileLayer);
    layers.add(_draftMarkerLayer);
    layers.add(_draftPolygonLayer);
    layers.add(_polygonLayer);
    layers.add(_expandedPolygonLayer);
    layers.add(_moreExpandedPolygonLayer);
    layers.add(_logMarkerLayer);
    _layersController.add(layers);
  }

  void createDraftPolygon(List<Marker> markers) {
    List<LatLng> points = new List();
    markers.forEach((marker) {
      points.add(marker.point);
    });

    _draftPolygons.clear();
    _draftPolygons.add(new Polygon(
      points: points,
      color: Color(Colors.grey.value - Constants.ALPHA_MASK),
      borderColor: Color(Colors.grey.value),
      borderStrokeWidth: 1.0,
    ));

    setLayers.add(layers);
  }

  void createPolygon() {
    if (_draftPolygons.isEmpty) {
      return;
    }
    Polygon polygon = _draftPolygons[0];
    _polygons.add(new Polygon(
        points: polygon.points,
        color: Color(Colors.red.value - Constants.ALPHA_MASK),
        borderColor: Color(Colors.red.value),
        borderStrokeWidth: 1.0));
    print("determined");
    setLayers.add(layers);

    _draftMarkers.clear();
    _draftPolygons.clear();
  }

  void removeAllPolygons() {
    _polygons.clear();
    _draftPolygons.clear();
    _draftMarkers.clear();
    _logMarkers.clear();
    setLayers.add(layers);
  }

  Future<void> removeAreaByAreaName(String areaName) async {
    await AreaRepository().getTableList().then((list) {
      if (list.contains(areaName)) {
        AreaRepository().removeTable(areaName).then((_) {
          print("$areaName:removed");
          return;
        });
      } else {
        print("area remove error : no such areaname");
        return;
      }
    });
  }

  void saveCurrentArea(String tableName) async {
    AreaRepository().getTableList().then((areaList) {
      if (areaList.contains(tableName)) {
        print("table name is already exist");
        return;
      } else {
        AreaRepository().createNewTable(tableName).then((_) {
          _polygons.forEach((polygon) {
            Area area =
                Area(areaPointsStr: Area.pointsToString(polygon.points));
            //area.areaPointsStr = Area.pointsToString(polygon.points);
            print(polygon.points.toString());
            AreaRepository().addDataToTable(tableName, area);
          });
        });
      }
    });
  }

  void readSavedArea(String tableName) async {
    AreaRepository().getPointsListByTableName(tableName).then((areaList) {
      if (areaList.isEmpty) {
        return;
      }
      _polygons.clear();
      areaList.forEach((points) {
        Polygon polygon = new Polygon(
            points: points,
            color: Color(Colors.red.value - Constants.ALPHA_MASK),
            borderColor: Color(Colors.red.value),
            borderStrokeWidth: 1.0);
        _polygons.add(polygon);
      });
      setLayers.add(layers);
    });
  }

  bool _polygonContainsPoint(Polygon polygon, LatLng point) {
    List<LatLng> points = polygon.points;
    num px = point.longitude;
    num py = point.latitude;

    num ax = 0;
    num ay = 0;
    num bx = points[points.length - 1].longitude - px;
    num by = points[points.length - 1].latitude - py;
    int depth = 0;

    for (int i = 0; i < points.length; i++) {
      ax = bx;
      ay = by;
      bx = points[i].longitude - px;
      by = points[i].latitude - py;

      if (ay < 0 && by < 0) continue; // both "up" or both "down"
      if (ay > 0 && by > 0) continue; // both "up" or both "down"
      if (ax < 0 && bx < 0) continue; // both points on left

      num lx = ax - ay * (bx - ax) / (by - ay);

      if (lx == 0) return true; // point on edge
      if (lx > 0) depth++;
    }

    return (depth & 1) == 1;
  }

  MapBloc() {
    _draftMarkers = new List();
    _logMarkers = new List();
    _draftPolygons = new List();
    _polygons = new List();
    _expandedPolygons = new List();
    _moreExpandedPolygons = new List();

    onAddPoint.listen((point) {
      double latitude = double.parse(point.latitude.toStringAsFixed(7));
      double longitude = double.parse(point.longitude.toStringAsFixed(7));

      Marker _marker = new Marker(
        width: 40.0,
        height: 80.0,
        point: LatLng(latitude, longitude),
        builder: (ctx) => new Container(
          child: new FlutterLogo(),
        ),
      );

      if (_draftMarkers.length >= 1) {
        if ((_draftMarkers[_draftMarkers.length - 1].point.latitude ==
                point.latitude) &&
            (_draftMarkers[_draftMarkers.length - 1].point.longitude ==
                point.longitude)) {
          return; //同じ座標に連続してマーカーは置けない
        }
      }
      _draftMarkers.add(_marker);
      setLayers.add(layers);
      print(point);
      if (_draftMarkers.length > 2) {
        createDraftPolygon(_draftMarkers);
      }
    });

    onCurrentLocationChanged.listen((point) {
      bool result = false;
      _polygons.forEach((polygon) {
        if (_polygonContainsPoint(polygon, point)) {
          print("inside");
          result = true;
        } else {
          print("outside");
        }
      });
      if (result) {
        Vibration.hasVibrator().then((bool) {
          if (bool) {
            Vibration.vibrate();
          }
        });
        _logMarkers.add(Marker(
          point: point,
          builder: (ctx) {
            return Icon(
              Icons.location_on,
              color: Colors.black,
            );
          },
          anchorPos: AnchorPos.align(AnchorAlign.top),
        ));
        setLayers.add(layers);
      } else {
        _logMarkers.add(Marker(
            point: point,
            builder: (ctx) {
              return Icon(
                Icons.location_off,
                color: Colors.green,
              );
            }));
        setLayers.add(layers);
      }
    });
  }
  @override
  void dispose() {
    _optionsController.close();
    _addPointController.close();
    _currentLocationController.close();
  }
}
