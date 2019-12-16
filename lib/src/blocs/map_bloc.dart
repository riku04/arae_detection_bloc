import 'dart:async';

import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';


class MapBloc extends Bloc{

  List<LatLng> _draftPoints;  //下書きポリゴンの座標点
  List<Marker> _draftMarkers; //下書きポリゴンのマーカー
  Polygon _draftPolygon;  //下書き中のポリゴン
  List<Polygon> _draftPolygons; //PolygonLayerOptionsに下書きポリゴンを渡すためのリスト、要素数が1以上になることはない
  List<Polygon> _polygons;      //こちらは禁止領域のポリゴン、複数になる
  List<Polygon> _expandedPolygons;  //接近領域
  List<Polygon> _moreExpandedPolygons;  //準接近領域

  final StreamController<MapOptions> _optionsController = StreamController<MapOptions>();
  Sink<MapOptions> get initOptions => _optionsController.sink;
  Stream<MapOptions> get onInitOptions => _optionsController.stream;

  void initMap(){
    MapOptions _mapOptions = new MapOptions(
        center: new LatLng(35.691075, 139.767828),
        zoom: 13.0,
        onTap: (_latLng) {

        });
    initOptions.add(_mapOptions);
    addMarker.add(_draftMarkers);
  }

  final _addPointController = StreamController<LatLng>.broadcast();
  Sink<LatLng> get addPoint => _addPointController.sink;
  Stream<LatLng> get onAddPoint => _addPointController.stream;

  StreamTransformer<LatLng, Marker> makeMarker(){
    return StreamTransformer<LatLng, Marker>.fromHandlers(
      handleData: (latlng,sink){
        sink.add(
          Marker(
            width: 40.0,
            height: 80.0,
            point: latlng,
          ));
      });
  }

  final _markersController = StreamController<List<Marker>>();
  Sink<List<Marker>> get addMarker => _markersController.sink;
  Stream<List<Marker>> get onAddMarker => _markersController.stream;

  MapBloc(){

    _draftMarkers = new List();

    onAddPoint.listen((point){
      Marker _marker = new Marker(
        width: 40.0,
        height: 80.0,
        point: point,
      );

      _draftMarkers.add(_marker);
      addMarker.add(new List<Marker>());
    });

  }
  @override
  void dispose() {
    // TODO: implement dispose
    _optionsController.close();
    _addPointController.close();
    _markersController.close();
  }

}