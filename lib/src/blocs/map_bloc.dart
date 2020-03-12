import 'dart:async';

import 'package:async/async.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_location/flutter_background_location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_app/src/models/area.dart';
import 'package:flutter_map_app/src/models/log_data.dart';
import 'package:flutter_map_app/src/models/user_settings.dart';
import 'package:flutter_map_app/src/repository/area_repository.dart';
import 'package:flutter_map_app/src/repository/user_settings_repository.dart';
import 'package:flutter_map_app/src/resources/constants.dart';
import 'package:flutter_map_app/src/utilities/helper.dart';
import 'package:flutter_map_app/src/utilities/logger.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vibration/vibration.dart';
import 'dart:math' as math;

class MapBloc extends Bloc {
  BuildContext context;
  AreaRepository _areaRepository;
  UserSettingsRepository _userSettingsRepository;
  
  Logger _logger;

  List<Marker> _draftMarkers; //下書きポリゴンのマーカー
  List<Polygon>_draftPolygons; //PolygonLayerOptionsに下書きポリゴンを渡すためのリスト、要素数が1以上になることはない

  List<Marker> _markers;  //移動履歴をリアルタイムで表示するマーカー
  List<Polyline> _lines;  //ポリライン
  List<Polygon> _polygons; //こちらは禁止領域のポリゴン、複数になる
  List<Polygon> _expandedPolygons; //接近領域
  List<Polygon> _moreExpandedPolygons; //準接近領域

  List<Marker> _logMarkers; //履歴ファイルを読み出して再生するときに使うマーカー
  List<Polyline> _logLines; //ポリライン
  List<Polygon> _logPolygons; //履歴ファイルから読み出した領域データ
  List<Polygon> _logExpandedPolygons; //接近

  List<LayerOptions> layers; //画面更新はこいつをStreamに流すことで行う

  TileLayerOptions _tileLayer; //地図タイルのレイヤ
  MarkerLayerOptions _draftMarkerLayer; //下書きマーカーのレイヤ
  MarkerLayerOptions _markerLayer;
  PolylineLayerOptions _lineLayer;
  MarkerLayerOptions _logMarkerLayer;
  PolylineLayerOptions _logLineLayer;
  PolygonLayerOptions _draftPolygonLayer; //下書きポリゴンのレイヤ
  PolygonLayerOptions _polygonLayer; //禁止領域ポリゴンのレイヤ
  PolygonLayerOptions _expandedPolygonLayer; //接近領域ポリゴンのレイヤ
  PolygonLayerOptions _moreExpandedPolygonLayer; //準接近領域ポリゴンのレイヤ
  PolygonLayerOptions _logPolygonLayer;
  PolygonLayerOptions _logExpandedPolygonLayer;

  bool isPolygonReady = false;
  int _logPlaySpeed = 1;

  LatLng lastPoint;

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

  final _currentLocationController = StreamController<LatLng>.broadcast(); //>>isInside,addLog
  Sink<LatLng> get addCurrentLocation => _currentLocationController.sink;
  Stream<LatLng> get onCurrentLocationChanged => _currentLocationController.stream;

  final _userSettingsController = StreamController<Map<String,dynamic>>();
  Sink<Map<String,dynamic>> get settings => _userSettingsController.sink;
  Stream<Map<String,dynamic>> get onSettingsChanged => _userSettingsController.stream;

  final _logPlayerVisibleController = StreamController<bool>.broadcast();
  Sink<bool> get logPlayerVisible => _logPlayerVisibleController.sink;
  Stream<bool> get onLogPlayerVisibleChanged => _logPlayerVisibleController.stream;

  final _logPLayerStateController = StreamController<int>.broadcast();
  Sink<int> get logPlayerState => _logPLayerStateController.sink;
  Stream<int> get onLogPlayerStateChanged => _logPLayerStateController.stream;

  final _logPlayerSpeedController = StreamController<int>.broadcast();
  Sink<int> get logPlayerSpeed => _logPlayerSpeedController.sink;
  Stream<int> get onLogPlayerSpeed => _logPlayerSpeedController.stream;

  final _logPlayerProgressController = StreamController<double>.broadcast();
  Sink<double> get logPlayerProgress => _logPlayerProgressController.sink;
  Stream<double> get onLogPlayerProgressUpdated => _logPlayerProgressController.stream;

  final _logCurrentTimeController = StreamController<DateTime>.broadcast();
  Sink<DateTime> get logCurrentTime => _logCurrentTimeController.sink;
  Stream<DateTime> get onLogCurrentTime => _logCurrentTimeController.stream;

  final _logTotalTimeController = StreamController<DateTime>.broadcast();
  Sink<DateTime> get logTotalTime => _logTotalTimeController.sink;
  Stream<DateTime> get onLogTotalTime => _logTotalTimeController.stream;


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
    _markerLayer = MarkerLayerOptions(markers: _markers);
    _lineLayer = PolylineLayerOptions(polylines: _lines);
    _logMarkerLayer = MarkerLayerOptions(markers: _logMarkers);
    _logLineLayer = PolylineLayerOptions(polylines: _logLines);
    _draftPolygonLayer = PolygonLayerOptions(polygons: _draftPolygons);
    _polygonLayer = PolygonLayerOptions(polygons: _polygons);
    _expandedPolygonLayer = PolygonLayerOptions(polygons: _expandedPolygons);
    _moreExpandedPolygonLayer = PolygonLayerOptions(polygons: _moreExpandedPolygons);
    _logPolygonLayer = PolygonLayerOptions(polygons: _logPolygons);
    _logExpandedPolygonLayer = PolygonLayerOptions(polygons: _logExpandedPolygons);
    layers.add(_tileLayer);
    layers.add(_draftPolygonLayer);
    layers.add(_polygonLayer);
    layers.add(_expandedPolygonLayer);
    layers.add(_moreExpandedPolygonLayer);
    layers.add(_logPolygonLayer);
    layers.add(_logExpandedPolygonLayer);
    layers.add(_logLineLayer);
    layers.add(_logMarkerLayer);
    layers.add(_markerLayer);
    layers.add(_draftMarkerLayer);
    layers.add(_lineLayer);
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

  void removeDraftPolygon(){
    _draftPolygons.clear();
    _draftMarkers.clear();
    setLayers.add(layers);
  }

  Future<void> createPolygon() async {
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
    setLogger();

    _draftMarkers.clear();
    _draftPolygons.clear();
    return;
  }

  void removeAllPolygons() {
    _polygons.clear();
    _expandedPolygons.clear();
    _moreExpandedPolygons.clear();
    setLogger();
    _markers.clear();
    _lines.clear();
    _draftPolygons.clear();
    _draftMarkers.clear();
    _logMarkers.clear();
    _logLines.clear();
    _logPolygons.clear();
    _logExpandedPolygons.clear();
    setLayers.add(layers);
  }

  Future<void> removeAreaByAreaName(String areaName) async {
    await _areaRepository.getTableList().then((list) {
      if (list.contains(areaName)) {
        _areaRepository.removeTable(areaName).then((_) {
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
    _areaRepository.getTableList().then((areaList) {
      if (areaList.contains(tableName)) {
        print("table name is already exist");
        return;
      } else {
        _areaRepository.createNewTable(tableName).then((_) {
          _polygons.forEach((polygon) {
            Area area =
                Area(areaPointsStr: Helper.pointsToString(polygon.points));
            //area.areaPointsStr = Area.pointsToString(polygon.points);
            print(polygon.points.toString());
            _areaRepository.addDataToTable(tableName, area);
          });
        });
      }
    });
  }

  void readSavedArea(String tableName) async {
    _areaRepository.getPointsListByTableName(tableName).then((areaList) {
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

  bool polygonContainsPoint(Polygon polygon, LatLng point) {
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

  //when userSettings or polygons changed call this to refresh the logger
  void setLogger() async{
    await _logger.initLogger(_polygons,await _userSettingsRepository.getTableData());
    print("logger refreshed");
  }

  List<DateTime> _tempDateTime = List();
  List<Marker> _tempLogMarkers = List();
  List<Polyline> _tempLogLines = List();
  double progressPeriod = 0.0;

  Future<void>setLogData(LogData logData) async{

    showLogPlayer();

    Stopwatch sw = Stopwatch();
    sw.start();

    _logMarkers.clear();
    _logLines.clear();
    _logPolygons.clear();
    _logExpandedPolygons.clear();

    await Future.forEach(logData.areas, (points){
      _logPolygons.add(Polygon(
          points: points,
          color: Color(Colors.yellow.value - Constants.ALPHA_MASK),
          borderColor: Color(Colors.yellow.value),
          borderStrokeWidth: 1.0)
      );
    });

    List<LatLng> tempLinePoints = List();

    int cnt = 0;
    Future.doWhile((){

      Color color;
      switch(logData.datePoints[cnt].getStatus()){
        case 0:
          color = Colors.indigo;
          break;
        case 1:
          color = Colors.red;
          break;
        case 2:
          color = Colors.yellowAccent;
          break;
        case 3:
          color = Colors.green;
          break;
      }

      Marker marker = Marker(
          point: logData.datePoints[cnt].getPoint(),
          anchorPos: AnchorPos.align(AnchorAlign.center),
          builder: (ctx) {
            return Icon(
              Icons.fiber_manual_record,
              color: color,
              size: 10,
            );
          });
      _tempLogMarkers.add(marker);
      _tempDateTime.add(logData.datePoints[cnt].getDateTime());

      if(cnt<=logData.datePoints.length-2){
        tempLinePoints.add(logData.datePoints[cnt].getPoint());
        tempLinePoints.add(logData.datePoints[cnt + 1].getPoint());
        _tempLogLines.add(Polyline(
            points: tempLinePoints.toList(),
            color: Colors.green,
            borderColor: Colors.green,
            borderStrokeWidth: 1.0
        ));
        tempLinePoints.clear();
      }
      if(cnt >= logData.datePoints.length-1){
        return false;
      }else{
        cnt++;
        return true;
      }
    });
    setLayers.add(layers);
    sw.stop();
    print("log read:${sw.elapsedMilliseconds}[ms]");
    print("log points:${_tempLogMarkers.length}");
    progressPeriod = 1.0 / _tempLogMarkers.length;

    logCurrentTime.add(_tempDateTime[0]);
    logTotalTime.add(_tempDateTime[_tempDateTime.length-1]);
    logPlayerProgress.add(0.0);

  return;
  }

  void showLogPlayer(){
    logPlayerVisible.add(true);
  }

  CancelableOperation runner;
  bool isPlayingLog = false;
  void startLogPlaying(){
    print("startLogPlaying");
    isPlayingLog = true;
    if(runner==null||runner.isCanceled){
      logPlayerState.add(Constants.LOG_PLAY_START);
      runner = CancelableOperation.fromFuture(
        Future.doWhile(()async{


          if(_logPlaySpeed>0) {
            if (_logMarkers.length == _tempLogMarkers.length) {
              runner.cancel();
              return false;
            }
            if (_logMarkers.length == 0) {
              _logMarkers.add(_tempLogMarkers[_logMarkers.length]);
              setLayers.add(layers);
              return true;
            }

            DateTime current = _tempDateTime[_logMarkers.length - 1];
            DateTime next = _tempDateTime[_logMarkers.length];
//            await Future.delayed(Duration(milliseconds: next.millisecondsSinceEpoch - current.millisecondsSinceEpoch));

            num delay = (next.millisecondsSinceEpoch-current.millisecondsSinceEpoch)/_logPlaySpeed.abs();
            int delayInt = delay.toInt();
            await Future.delayed(Duration(milliseconds: delayInt));

            _logMarkers.add(_tempLogMarkers[_logMarkers.length]);
            setLayers.add(layers);

            int totalTime = _tempDateTime[_tempDateTime.length - 1]
                .millisecondsSinceEpoch -
                _tempDateTime[0].millisecondsSinceEpoch;
            int spentTime = _tempDateTime[_logMarkers.length - 1]
                .millisecondsSinceEpoch -
                _tempDateTime[0].millisecondsSinceEpoch;
            double timeProgress = spentTime / totalTime;
            logPlayerProgress.add(timeProgress);

            print(
                "marker:${_logMarkers.length},total:${_tempLogMarkers.length}");
            return isPlayingLog;
          }else if(_logPlaySpeed < 0){

            if (_logMarkers.length == 1) {
              //_logMarkers.removeLast();
              setLayers.add(layers);
              runner.cancel();
              return false;
            }

            DateTime current = _tempDateTime[_logMarkers.length - 1];
            DateTime before = _tempDateTime[_logMarkers.length - 2];

            num delay = (current.millisecondsSinceEpoch-before.millisecondsSinceEpoch)/_logPlaySpeed.abs();
            int delayInt = delay.toInt();

            await Future.delayed(Duration(milliseconds: delayInt));
            _logMarkers.removeLast();
            setLayers.add(layers);

            int totalTime = _tempDateTime[_tempDateTime.length - 1]
                .millisecondsSinceEpoch -
                _tempDateTime[0].millisecondsSinceEpoch;
            int spentTime = _tempDateTime[_logMarkers.length - 1]
                .millisecondsSinceEpoch -
                _tempDateTime[0].millisecondsSinceEpoch;
            double timeProgress = spentTime / totalTime;
            logPlayerProgress.add(timeProgress);

            print(
                "marker:${_logMarkers.length},total:${_tempLogMarkers.length}");
            return isPlayingLog;
          }else{
            return false;
          }
         }),
          onCancel: (){
            print("canceled");
            logPlayerState.add(Constants.LOG_PLAY_STOP);
          },
      );
    }
  }

  void upPlaySpeed(){
    if(_logPlaySpeed==-4){
      _logPlaySpeed = -2;
      logPlayerSpeed.add(-2);
    }
    else if(_logPlaySpeed==-2){
      _logPlaySpeed = -1;
      logPlayerSpeed.add(-1);
    }
    else if(_logPlaySpeed==-1){
      _logPlaySpeed = 1;
      logPlayerSpeed.add(1);
    }
    else if(_logPlaySpeed==1){
      _logPlaySpeed = 2;
      logPlayerSpeed.add(2);
    }else if(_logPlaySpeed==2){
      _logPlaySpeed = 4;
      logPlayerSpeed.add(4);
    }
    print("speed:$_logPlaySpeed");
  }

  void downPlaySpeed(){
    if(_logPlaySpeed==4){
      _logPlaySpeed = 2;
      logPlayerSpeed.add(2);
    }
    else if(_logPlaySpeed==2){
      _logPlaySpeed = 1;
      logPlayerSpeed.add(1);
    }
    else if(_logPlaySpeed==1){
      _logPlaySpeed = -1;
      logPlayerSpeed.add(-1);
    }
    else if(_logPlaySpeed==-1){
      _logPlaySpeed = -2;
      logPlayerSpeed.add(-2);
    }else if(_logPlaySpeed==-2){
      _logPlaySpeed = -4;
      logPlayerSpeed.add(-4);
    }
    print("speed:$_logPlaySpeed");
  }

  void setLogPlaySpeed(int speed){
    _logPlaySpeed = speed;
  }

  void stopLogPlaying(){
    print("stopLogPlaying");
    if(runner!=null){
      isPlayingLog = false;
      runner.cancel();
    }
  }

  void toggleLogPlaying(){
    if(isPlayingLog==true){
      stopLogPlaying();
    }else{
      startLogPlaying();
    }
  }

  MapBloc(BuildContext context,AreaRepository areaRepository,UserSettingsRepository userSettingsRepository)  {
    this._areaRepository = areaRepository;
    this._userSettingsRepository = userSettingsRepository;
    
    _draftMarkers = List();
    _markers = List();
    _lines = List();
    _logMarkers = List();
    _logLines = List();
    _draftPolygons = List();
    _polygons = List();
    _expandedPolygons = List();
    _moreExpandedPolygons = List();
    _logPolygons = List();
    _logExpandedPolygons = List();

    _logger = Logger();
    setLogger();
    onSettingsChanged.listen((settings) {
      print("settings changed");
      setLogger();
      //Fluttertoast.showToast(msg: "保存しました");
    });

    FlutterBackgroundLocation.startLocationService();
    FlutterBackgroundLocation.getLocationUpdates((point){
      print("point: ${point.latitude},${point.longitude}");
      addCurrentLocation.add(LatLng(point.latitude,point.longitude));
    });

    onAddPoint.listen((point) {
      double latitude = double.parse(point.latitude.toStringAsFixed(7));
      double longitude = double.parse(point.longitude.toStringAsFixed(7));

      Marker _marker = new Marker(
        point: LatLng(latitude, longitude),
        anchorPos: AnchorPos.align(AnchorAlign.top),
        builder: (ctx) => new Container(
          child: Icon(Icons.location_on,color: Colors.pinkAccent,),
        ),
      );

      if (_draftMarkers.length >= 1) {
        if ((_draftMarkers[_draftMarkers.length - 1].point.latitude == point.latitude) &&
            (_draftMarkers[_draftMarkers.length - 1].point.longitude == point.longitude)) {
          return; //同じ座標に連続してマーカーは置けない
        }
      }
      _draftMarkers.add(_marker);
      setLayers.add(layers);
      print(point);
      if (_draftMarkers.length > 2) {
        createDraftPolygon(_draftMarkers);
        isPolygonReady = true;
        print(isPolygonReady);
      }else{
        isPolygonReady = false;
        print(isPolygonReady);
      }
    });

    onCurrentLocationChanged.listen((point) async {
      lastPoint = point;
      int result = 0;
      _polygons.forEach((polygon) {
        if (polygonContainsPoint(polygon, point)) {
          print("inside");
          result = 1;
        } else {
          print("outside");
        }
      });
      if (result==1) {
        Vibration.hasVibrator().then((bool) {
          if (bool) {
            Vibration.vibrate();
          }
        });
        _markers.add(Marker(
          point: point,
          builder: (ctx) {
            return Icon(
              Icons.location_on,
              color: Colors.yellowAccent,
            );
          },
          anchorPos: AnchorPos.align(AnchorAlign.top),
        ));
        setLayers.add(layers);
      } else {
        _markers.add(Marker(
            point: point,
            builder: (ctx) {
              return Icon(
                Icons.location_on,
                color: Colors.green,
              );
            }));
        setLayers.add(layers);
      }
      await _logger.addLog(DateTime.now(), point, result);
    });

    logPlayerSpeed.add(1);
    logPlayerProgress.add(0.0);
    logPlayerState.add(Constants.LOG_PLAY_STOP);
    logPlayerVisible.add(false);

    onLogPlayerProgressUpdated.listen((progress)async{
      if(_logMarkers.length==0){
        _logMarkers.add(_tempLogMarkers[0]);
        setLayers.add(layers);
        return;
      }

      int totalTime = _tempDateTime[_tempDateTime.length-1].millisecondsSinceEpoch - _tempDateTime[0].millisecondsSinceEpoch;
      int spentTime = _tempDateTime[_logMarkers.length - 1].millisecondsSinceEpoch - _tempDateTime[0].millisecondsSinceEpoch;
      double timeProgress = spentTime / totalTime;
      double currentMarkerProgress = _logMarkers.length/_tempLogMarkers.length;

      print("time:${timeProgress},progress:${progress}");

      if(timeProgress<progress) {
        await Future.doWhile(() {
           _logMarkers.add(_tempLogMarkers[_logMarkers.length]);
           if (_logMarkers.length / _tempLogMarkers.length <= progress || _logMarkers.length == _tempLogMarkers.length) {
            print("marker:${_logMarkers.length},total:${_tempLogMarkers.length}");
            return true;
          } else {
            return false;
          }
        });
      }else if(timeProgress>progress){
        await Future.doWhile(() {
           _logMarkers.removeLast();
           if (_logMarkers.length / _tempLogMarkers.length >= progress) {
            print("marker:${_logMarkers.length},total:${_tempLogMarkers.length}");
            return true;
          } else {
            return false;
          }
        });
      }

      _logLines.clear();
      await Future.doWhile((){
        if(_logLines.length<=_logMarkers.length-2){
          _logLines.add(_tempLogLines[_logLines.length]);
          return true;
        }else{
          return false;
        }
      });

      logCurrentTime.add(_tempDateTime[_logMarkers.length-1]);
      setLayers.add(layers);
      print(progress);
    });

    onLogPlayerVisibleChanged.listen((visible){
      if(visible == false){

        if(runner!=null) {
          runner.cancel();
        }

        _logMarkers.clear();
        _logLines.clear();
        _logPolygons.clear();
        _tempLogMarkers.clear();
        _tempLogLines.clear();
        _tempDateTime.clear();
        setLayers.add(layers);
      }
    });


  }
  @override
  void dispose() {
    _optionsController.close();
    _addPointController.close();
    _currentLocationController.close();
    _userSettingsController.close();
    _logPlayerVisibleController.close();
    _logPLayerStateController.close();
    _logPlayerSpeedController.close();
    _logPlayerProgressController.close();
    _logCurrentTimeController.close();
    _logTotalTimeController.close();
  }
}
