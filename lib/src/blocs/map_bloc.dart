import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:flutter_map_app/src/widgets/space_box.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong/latlong.dart';
import 'package:rxdart/rxdart.dart';
import 'package:soundpool/soundpool.dart';
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

  List<int> _logStatusNum;
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

  double _closeDistance = 10;

  bool isPolygonReady = false;
  int _logPlaySpeed = 1;

  LatLng lastPoint;

  String groupIdString = "";
  String userIdString = "";

  bool isAlertEnable = false;
  Soundpool soundpool;
  int closeAlertId;
  int enterAlertId;
  bool hasCloseAlert = false;
  bool hasEnterAlert = false;

  bool isCalcLocationEnable = false;

  MapController _mapController;

  void setMapController(MapController mc){
    this._mapController = mc;
  }

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

  final _userSettingsController = StreamController<Map<String,dynamic>>.broadcast();
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

  final _alertEnableController = StreamController<bool>.broadcast();
  Sink<bool> get alertEnable => _alertEnableController.sink;
  Stream<bool> get onAlertEnableChanged => _alertEnableController.stream;

  final _logStatusController = StreamController<int>.broadcast();
  Sink<int> get logStatus => _logStatusController.sink;
  Stream<int> get onLogStatusChanged => _logStatusController.stream;

  final _calcLocationController = StreamController<bool>.broadcast();
  Sink<bool> get calcLocation => _calcLocationController.sink;
  Stream<bool> get onCalcLocationChanged => _calcLocationController.stream;

  bool isLongPressed = false;

  final _selectPolygonController = StreamController<Polygon>.broadcast();
  Sink<Polygon> get selectPolygon => _selectPolygonController.sink;
  Stream<Polygon> get onSelectPolygon => _selectPolygonController.stream;

  final _isSearchingContoller = StreamController<bool>.broadcast();
  Sink<bool> get isSearching => _isSearchingContoller.sink;
  Stream<bool> get onIsSearchingChanged => _isSearchingContoller.stream;

  void initMapOptions() {
    MapOptions _mapOptions = new MapOptions(
        center: new LatLng(35.691075, 139.767828),
        zoom: 13.0,
        onTap: (_latLng) {
          addCurrentLocation.add(_latLng);
        },
        onLongPress:(_latLng){
          print("long pressed");
          if(isLongPressed == false) {
            isLongPressed = true;
            _polygons.forEach((polygon) {
              if (polygonContainsPoint(polygon, _latLng)) {
                selectPolygon.add(polygon);
                isLongPressed = false;
                return;
              }
            });
          }
        }
        );
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
      _mapController.move(_polygons[_polygons.length-1].points[0], _mapController.zoom);
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

  bool polygonCloserPoint(Polygon polygon, LatLng point, double distance){
    bool closer = false;

    double rad = 0;
    const double addition = 0.1;

    while(rad<=2){

      LatLng rotated = LatLng(point.latitude,point.longitude);
      double r = 0.0;

      while(calcDistance(point, rotated)<=distance){
        double lat = point.latitude + r * math.sin(rad * math.pi);
        double lon = point.longitude + r * math.cos(rad * math.pi);
        rotated = LatLng(lat,lon);
        r+=0.000001;
      }

//      Marker marker = Marker(
//          point: rotated,
//          anchorPos: AnchorPos.align(AnchorAlign.center),
//          builder: (ctx) {
//            return Icon(
//              Icons.fiber_manual_record,
//              color: Colors.lightBlueAccent,
//              size: 10,
//            );
//          }
//      );
//      _markers.add(marker);
//      setLayers.add(layers);

//      print(calcDistance(point, rotated));
//      print(rotated);

      if(polygonContainsPoint(polygon, rotated)){
        closer = true;
        break;
      }

      rad += addition;
    }
    //print("close?:$closer");
    return closer;
  }

  double calcDistance(LatLng p1, LatLng p2){
    final double GRS80_A = 6378137.000;//長半径 a(m)
    final double GRS80_E2 = 0.00669438002301188;//第一遠心率  eの2乗
    double lon1 = p1.longitude;
    double lat1 = p1.latitude;
    double lon2 = p2.longitude;
    double lat2 = p2.latitude;
    double my = degToRadian((lat1 + lat2) / 2.0); //緯度の平均値
    double dy = degToRadian(lat1 - lat2); //緯度の差
    double dx = degToRadian(lon1 - lon2); //経度の差
    //卯酉線曲率半径を求める(東と西を結ぶ線の半径)
    double sinMy = math.sin(my);
    double w = math.sqrt(1.0 - GRS80_E2 * sinMy * sinMy);
    double n = GRS80_A / w;
    //子午線曲線半径を求める(北と南を結ぶ線の半径)
    double mnum = GRS80_A * (1 - GRS80_E2);
    double m = mnum / (w * w * w);
    //ヒュベニの公式
    double dym = dy * m;
    double dxncos = dx * n * math.cos(my);
    return math.sqrt(dym * dym + dxncos * dxncos);
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

      //outside 0, close 1, inside 2
      Color color;
      switch(logData.datePoints[cnt].getStatus()){
        case 0:
          _logStatusNum.add(0);
          color = Colors.lightBlue;
          break;
        case 1:
          _logStatusNum.add(1);
          color = Colors.orange;
          break;
        case 2:
          _logStatusNum.add(2);
          color = Colors.pink;
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

    await Future.delayed((Duration(milliseconds: 100)),(){
      logCurrentTime.add(_tempDateTime[0]);
      logTotalTime.add(_tempDateTime[_tempDateTime.length-1]);
    });

    logPlayerProgress.add(0.0);
    this._mapController.move(_tempLogMarkers[0].point, this._mapController.zoom);
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
              logStatus.add(_logStatusNum[_logMarkers.length]);
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
            logStatus.add(_logStatusNum[_logMarkers.length]);
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
            logStatus.add(_logStatusNum[_logMarkers.length]);
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
    _logStatusNum = List();
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


    UserSettingsRepository().getTableData().then((settings)async{
      this.userIdString = settings["USER_ID"];
      this.groupIdString = settings["GROUP_ID"];
      if(settings["CLOSE_ALERT_ON"]==1){
        this.hasCloseAlert = true;
      }
      if(settings["ENTER_ALERT_ON"]==1){
        this.hasEnterAlert = true;
      }

      if(soundpool==null) {
        soundpool = Soundpool(streamType: StreamType.music);
        closeAlertId = await rootBundle.load("sounds/pupu.mp3").then((ByteData soundData) {
          return soundpool.load(soundData);
        });
        enterAlertId = await rootBundle.load("sounds/pii.mp3").then((ByteData soundData) {
          return soundpool.load(soundData);
        });
      }

      _closeDistance = settings["CLOSE_DISTANCE_METER"] * 1.0;

    });

    onSettingsChanged.listen((settings) {
      print("settings changed");
      setLogger();
      this.userIdString = settings["USER_ID"];
      this.groupIdString = settings["GROUP_ID"];
      if(settings["CLOSE_ALERT_ON"]==1){
        this.hasCloseAlert = true;
      }
      if(settings["ENTER_ALERT_ON"]==1){
        this.hasEnterAlert = true;
      }
      _closeDistance = settings["CLOSE_DISTANCE_METER"] * 1.0;

      //Fluttertoast.showToast(msg: "保存しました");
    });

    LatLng oldPoint = LatLng(0,0);//geoLocationUpdatesで同じ座標が複数回連続で呼ばれる問題対策
    FlutterBackgroundLocation.startLocationService();
    FlutterBackgroundLocation.getLocationUpdates((point){
      print("point: ${point.latitude},${point.longitude}");

      if(oldPoint.latitude==point.latitude
      &&oldPoint.longitude==point.longitude){
        return;
      }
      addCurrentLocation.add(LatLng(point.latitude,point.longitude));
      oldPoint.latitude = point.latitude;
      oldPoint.longitude = point.longitude;

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

    //outside 0, close 1, inside 2
    onCurrentLocationChanged.listen((point) async {

//      if(isCalcLocationEnable) {
//        _mapController.move(point, _mapController.zoom);
//      }

      lastPoint = point;
      int result = 0;
      _polygons.forEach((polygon) {
        if (polygonContainsPoint(polygon, point)) {
          print("inside");
          result = 2;
        }else if(polygonCloserPoint(polygon, point, _closeDistance)){
          print("close");
          result = 1;
        } else {
          print("outside");
        }
      });
      if (result == Constants.INSIDE) {

        if(this.isAlertEnable) {
          Vibration.hasVibrator().then((bool) {
            if (bool) {
              Vibration.vibrate();
            }
          });

          if (this.hasEnterAlert) {
            //alert
            await soundpool.play(enterAlertId);
            print("enter alert here!");
          }
        }

        _markers.add(
            Marker(
              point: point,
              anchorPos: AnchorPos.align(AnchorAlign.top),
              builder: (ctx) {
                return Icon(
                  Icons.location_on,
                  color: Colors.pink,
                );
                },
            ));
        setLayers.add(layers);

      } else if(result == Constants.CLOSE) {

        if(this.isAlertEnable) {
          Vibration.hasVibrator().then((bool) {
            if (bool) {
              Vibration.vibrate();
            }
          });

          if (this.hasCloseAlert) {
            //alert
            await soundpool.play(closeAlertId);
            print("close alert here!");
          }
        }

        _markers.add(
            Marker(
              point: point,
              anchorPos: AnchorPos.align(AnchorAlign.top),
              builder: (ctx) {
                return Icon(
                  Icons.location_on,
                  color: Colors.orange,
                );
                },
            ));
        setLayers.add(layers);

      }else if(result == Constants.OUTSIDE){
        _markers.add(
            Marker(
                point: point,
                builder: (ctx) {
                  return Icon(
                    Icons.location_on,
                    color: Colors.lightBlue,
                  );
                }
            ));
        setLayers.add(layers);
      }

      if(_markers.length>=50){
        _markers.removeAt(0);
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

      logStatus.add(_logStatusNum[_logMarkers.length]);
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

    onLogStatusChanged.listen((status)async{
      if(status == Constants.INSIDE){
        if(this.isAlertEnable) {
          Vibration.hasVibrator().then((bool) {
            if (bool) {
              Vibration.vibrate();
            }
          });
          if (this.hasCloseAlert) {
            //alert
            await soundpool.play(enterAlertId);
            print("close alert here!");
          }
        }
      }else if(status == Constants.CLOSE){
        if(this.isAlertEnable) {
          Vibration.hasVibrator().then((bool) {
            if (bool) {
              Vibration.vibrate();
            }
          });
          if (this.hasCloseAlert) {
            //alert
            await soundpool.play(closeAlertId);
            print("close alert here!");
          }
        }
      }else if(status == Constants.OUTSIDE){

      }
    });

    CancelableOperation calculator;
    onCalcLocationChanged.listen((bool)async{
      print("calculate location start");
      isCalcLocationEnable = bool;
      if(bool){
        //wait 10 sec
        if(calculator==null||calculator.isCanceled||calculator.isCompleted){
          calculator = CancelableOperation.fromFuture(
            Future.delayed(Duration(seconds: 10),(){
              print("calculate location stop");
              calcLocation.add(false);
              isCalcLocationEnable = false;
            })
          );
        }
      }else{
        print("calclating");
      }
    });

    alertEnable.add(false);
    onAlertEnableChanged.listen((bool){
      this.isAlertEnable = bool;
    });
  }

  Future<void> searchAndMoveToPlace(String key) async {
    if(key==""){
      return;
    }
    final query = key;
    isSearching.add(true);
    try {
      var addresses = await Geocoder.local.findAddressesFromQuery(query);
      isSearching.add(false);
      var first = addresses.first;
      _mapController.move(LatLng(first.coordinates.latitude,first.coordinates.longitude), _mapController.zoom);
      print("${first.featureName} : ${first.coordinates}");
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
      print(e.toString());
    }
    return;
  }

  void removePolygon(polygon){
    if(_polygons.contains(polygon)) {
      _polygons.remove(polygon);
      setLayers.add(layers);
      removeAreaByAreaName(Constants.DEFAULT_AREA_TABLE).then((_){
        saveCurrentArea(Constants.DEFAULT_AREA_TABLE);
      });
      setLogger();
    }
  }

  void toggleAlertEnable(){
      alertEnable.add(!isAlertEnable);
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
    _alertEnableController.close();
    _logStatusController.close();
    _calcLocationController.close();
    _selectPolygonController.close();
    _isSearchingContoller.close();
  }
}
