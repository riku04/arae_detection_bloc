
import 'dart:async';

import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter_map_app/src/blocs/map_bloc.dart';
import 'package:flutter_map_app/src/models/user_settings.dart';
import 'package:flutter_map_app/src/repository/user_settings_repository.dart';

class SettingBloc extends Bloc{

  UserSettingsRepository _repository;
  Map<String,dynamic> _settings; //DBから読み出したパラメータ
  UserSettings _tempUserSettings; //変更後のパラメータ

  void setTempUserId(String userId){
    _tempUserSettings.userId = userId;
  }
  void setTempGroupId(String groupId){
    _tempUserSettings.groupId = groupId;
  }
  void setTempAdmin(int hasAdmin){
    _tempUserSettings.admin = hasAdmin;
  }
  void setTempEnterAlertOn(int isEnterAlertOn){
    _tempUserSettings.enterAlertOn = isEnterAlertOn;
  }
  void setTempCloseAlertOn(int isCloseAlertOn){
    _tempUserSettings.closeAlertOn = isCloseAlertOn;
  }
  void setTempBeaconAlertOn(int isBeaconAlertOn){
    _tempUserSettings.beaconAlertOn = isBeaconAlertOn;
  }
  void setTempVibrationOn(int isVibrationOn){
    _tempUserSettings.vibrationOn = isVibrationOn;
  }
  void setTempLoggingOn(int isLoggingOn){
    _tempUserSettings.loggingOn = isLoggingOn;
  }
  void setTempStartHour(int startHour){
    _tempUserSettings.startHour = startHour;
  }
  void setTempStartMinute(int startMinute){
    _tempUserSettings.startMinute = startMinute;
  }
  void setTempEndHour(int endHour){
    _tempUserSettings.endHour = endHour;
  }
  void setTempEndMinute(int endMinute){
    _tempUserSettings.endMinute = endMinute;
  }
  void setTempStartLunchHour(int startLunchHour){
    _tempUserSettings.startLunchHour = startLunchHour;
  }
  void setTempStartLunchMinute(int startLunchMinute){
    _tempUserSettings.startLunchMinute = startLunchMinute;
  }
  void setTempEndLunchHour(int endLunchHour){
    _tempUserSettings.endLunchHour = endLunchHour;
  }
  void setTempEndLunchMinute(int endLunchMinute){
    _tempUserSettings.endLunchMinute = endLunchMinute;
  }
  void setTempCloseDistanceMeter(int closeDistanceMeter){
    _tempUserSettings.closeDistanceMeter = closeDistanceMeter;
  }
  void setTempBeaconCloseDistanceMeter(int beaconCloseDistanceMeter){
    _tempUserSettings.beaconCloseDistanceMeter = beaconCloseDistanceMeter;
  }
  void setTempLogIntervalSec(int logIntervalSec){
    _tempUserSettings.logIntervalSec = logIntervalSec;
  }
  void setTempSemiCloseLogIntervalSec(int semiCloseLogIntervalSec){
    _tempUserSettings.semiCloseLogIntervalSec = semiCloseLogIntervalSec;
  }
  void setTempCloseLogIntervalSec(int closeLogIntervalSec){
    _tempUserSettings.closeLogIntervalSec = closeLogIntervalSec;
  }
  void setTempEnterLogIntervalSec(int enterLogIntervalSec){
    _tempUserSettings.enterLogIntervalSec = enterLogIntervalSec;
  }
  void setTempBeaconLogIntervalSec(int beaconLogIntervalSec){
    _tempUserSettings.beaconLogIntervalSec = beaconLogIntervalSec;
  }
  void setTempBeaconNameListString(String beaconNameListString){
    _tempUserSettings.beaconNameListString = beaconNameListString;
  }

  final _userIdController = StreamController<String>();
  Sink<String> get userId => _userIdController.sink;
  Stream<String> get onUserId => _userIdController.stream;

  final _groupIdController = StreamController<String>();
  Sink<String> get groupId => _groupIdController.sink;
  Stream<String> get onGroupId => _groupIdController.stream;

  final _adminController = StreamController<int>();
  Sink<int> get admin => _adminController.sink;
  Stream<int> get onAdmin => _adminController.stream;

  final _enterAlertOnController = StreamController<int>();
  Sink<int> get enterAlertOn => _enterAlertOnController.sink;
  Stream<int> get onEnterAlertON => _enterAlertOnController.stream;

  final _closeAlertOnController = StreamController<int>();
  Sink<int> get closeAlertOn => _closeAlertOnController.sink;
  Stream<int> get onCloseAlertOn => _closeAlertOnController.stream;

  final _beaconAlertOnController = StreamController<int>();
  Sink<int> get beaconAlertOn => _beaconAlertOnController.sink;
  Stream<int> get onBeaconAlertOn => _beaconAlertOnController.stream;

  final _vibrationOnController = StreamController<int>();
  Sink<int> get vibrationOn => _vibrationOnController.sink;
  Stream<int> get onVibrationOn => _vibrationOnController.stream;

  final _loggingOnController = StreamController<int>();
  Sink<int> get loggingOn => _loggingOnController.sink;
  Stream<int> get onLoggingOn => _loggingOnController.stream;

  final _startHourController = StreamController<int>();
  Sink<int> get startHour => _startHourController.sink;
  Stream<int> get onStartHour => _startHourController.stream;

  final _startMinuteController = StreamController<int>();
  Sink<int> get startMinute => _startMinuteController.sink;
  Stream<int> get onStartMinute => _startMinuteController.stream;

  final _startLunchHourController = StreamController<int>();
  Sink<int> get startLunchHour => _startLunchHourController.sink;
  Stream<int> get onStartLunchHour => _startLunchHourController.stream;

  final _startLunchMinuteController = StreamController<int>();
  Sink<int> get startLunchMinute => _startLunchMinuteController.sink;
  Stream<int> get onStartLunchMinute => _startLunchMinuteController.stream;

  final _endLunchHourController = StreamController<int>();
  Sink<int> get endLunchHour => _endLunchHourController.sink;
  Stream<int> get onEndLunchHour => _endLunchHourController.stream;

  final _endLunchMinuteController = StreamController<int>();
  Sink<int> get endLunchMinute => _endLunchMinuteController.sink;
  Stream<int> get onEndLunchMinute => _endLunchMinuteController.stream;

  final _endHourController = StreamController<int>();
  Sink<int> get endHour => _endHourController.sink;
  Stream<int> get onEndHour => _endHourController.stream;

  final _endMinuteController = StreamController<int>();
  Sink<int> get endMinute => _endMinuteController.sink;
  Stream<int> get onEndMinute => _endMinuteController.stream;

  final _closeDistanceMeterController = StreamController<int>();
  Sink<int> get closeDistanceMeter => _closeDistanceMeterController.sink;
  Stream<int> get onCloseDistanceMeter => _closeDistanceMeterController.stream;

  final _beaconCloseDistanceMeterController = StreamController<int>();
  Sink<int> get beaconCloseDistanceMeter => _beaconCloseDistanceMeterController.sink;
  Stream<int> get onBeaconCloseDistanceMeter => _beaconCloseDistanceMeterController.stream;

  final _logIntervalSecController = StreamController<int>();
  Sink<int> get logIntervalSec => _logIntervalSecController.sink;
  Stream<int> get onLogIntervalSec => _logIntervalSecController.stream;

  final _semiCloseLogIntervalSecController = StreamController<int>();
  Sink<int> get semiCloseLogIntervalSec => _semiCloseLogIntervalSecController.sink;
  Stream<int> get onSemiCloseLogIntervalSec => _semiCloseLogIntervalSecController.stream;

  final _closeLogIntervalSecController = StreamController<int>();
  Sink<int> get closeLogIntervalSec => _closeLogIntervalSecController.sink;
  Stream<int> get onCloseLogIntervalSec => _closeLogIntervalSecController.stream;

  final _enterLogIntervalSecController = StreamController<int>();
  Sink<int> get enterLogIntervalSec => _enterLogIntervalSecController.sink;
  Stream<int> get onEnterLogIntervalSec => _enterLogIntervalSecController.stream;

  final _beaconLogIntervalSecController = StreamController<int>();
  Sink<int> get beaconLogIntervalSec => _beaconLogIntervalSecController.sink;
  Stream<int> get onBeaconLogIntervalSec => _beaconLogIntervalSecController.stream;

  final _beaconNameListStringController = StreamController<String>();
  Sink<String> get beaconNameListString => _beaconNameListStringController.sink;
  Stream<String> get onBeaconNameListString => _beaconNameListStringController.stream;

  void readCurrentSettings() async{
    _settings = Map.from(await _repository.getTableData());

    setTempUserId(_settings[UserSettings.USER_ID]);
    setTempGroupId(_settings[UserSettings.GROUP_ID]);
    setTempAdmin(_settings[UserSettings.ADMIN]);
    setTempEnterAlertOn(_settings[UserSettings.ENTER_ALERT_ON]);
    setTempCloseAlertOn(_settings[UserSettings.CLOSE_ALERT_ON]);
    setTempBeaconAlertOn(_settings[UserSettings.BEACON_ALERT_ON]);
    setTempVibrationOn(_settings[UserSettings.VIBRATION_ON]);
    setTempLoggingOn(_settings[UserSettings.LOGGING_ON]);
    setTempStartHour(_settings[UserSettings.START_HOUR]);
    setTempStartMinute(_settings[UserSettings.START_MINUTE]);
    setTempStartLunchHour(_settings[UserSettings.START_LUNCH_HOUR]);
    setTempStartLunchMinute(_settings[UserSettings.START_LUNCH_MINUTE]);
    setTempEndLunchHour(_settings[UserSettings.END_LUNCH_HOUR]);
    setTempEndLunchMinute(_settings[UserSettings.END_LUNCH_MINUTE]);
    setTempEndHour(_settings[UserSettings.END_HOUR]);
    setTempEndMinute(_settings[UserSettings.END_MINUTE]);
    setTempCloseDistanceMeter(_settings[UserSettings.CLOSE_DISTANCE_METER]);
    setTempCloseLogIntervalSec(_settings[UserSettings.BEACON_CLOSE_DISTANCE_METER]);
    setTempLogIntervalSec(_settings[UserSettings.LOG_INTERVAL_SEC]);
    setTempSemiCloseLogIntervalSec(_settings[UserSettings.SEMI_CLOSE_LOG_INTERVAL_SEC]);
    setTempCloseLogIntervalSec(_settings[UserSettings.CLOSE_LOG_INTERVAL_SEC]);
    setTempEnterLogIntervalSec(_settings[UserSettings.ENTER_LOG_INTERVAL_SEC]);
    setTempBeaconLogIntervalSec(_settings[UserSettings.BEACON_LOG_INTERVAL_SEC]);
    setTempBeaconNameListString(_settings[UserSettings.BEACON_NAME_LIST_STRING]);
    
    userId.add(_settings[UserSettings.USER_ID]);
    groupId.add(_settings[UserSettings.GROUP_ID]);
    admin.add(_settings[UserSettings.ADMIN]);
    enterAlertOn.add(_settings[UserSettings.ENTER_ALERT_ON]);
    closeAlertOn.add(_settings[UserSettings.CLOSE_ALERT_ON]);
    beaconAlertOn.add(_settings[UserSettings.BEACON_ALERT_ON]);
    vibrationOn.add(_settings[UserSettings.VIBRATION_ON]);
    loggingOn.add(_settings[UserSettings.LOGGING_ON]);
    startHour.add(_settings[UserSettings.START_HOUR]);
    startMinute.add(_settings[UserSettings.START_MINUTE]);
    startLunchHour.add(_settings[UserSettings.START_LUNCH_HOUR]);
    startLunchMinute.add(_settings[UserSettings.START_LUNCH_MINUTE]);
    endLunchHour.add(_settings[UserSettings.END_LUNCH_HOUR]);
    endLunchMinute.add(_settings[UserSettings.END_LUNCH_MINUTE]);
    endHour.add(_settings[UserSettings.END_HOUR]);
    endMinute.add(_settings[UserSettings.END_MINUTE]);
    closeDistanceMeter.add(_settings[UserSettings.CLOSE_DISTANCE_METER]);
    beaconCloseDistanceMeter.add(_settings[UserSettings.BEACON_CLOSE_DISTANCE_METER]);
    logIntervalSec.add(_settings[UserSettings.LOG_INTERVAL_SEC]);
    semiCloseLogIntervalSec.add(_settings[UserSettings.SEMI_CLOSE_LOG_INTERVAL_SEC]);
    closeLogIntervalSec.add(_settings[UserSettings.CLOSE_LOG_INTERVAL_SEC]);
    enterLogIntervalSec.add(_settings[UserSettings.ENTER_LOG_INTERVAL_SEC]);
    beaconLogIntervalSec.add(_settings[UserSettings.BEACON_LOG_INTERVAL_SEC]);
    beaconNameListString.add(_settings[UserSettings.BEACON_NAME_LIST_STRING]);
  }
  
  Future<Map<String,dynamic>> save() async{
    Map<String,dynamic> userSettingsMap = _tempUserSettings.toJson();
    List<String> keys = userSettingsMap.keys.toList();
    for(int i=0; i<= userSettingsMap.length-1; i++){
      if(userSettingsMap[keys[i]]!=_settings[keys[i]]){
        print("key:${keys[i]}");
        print("new[${userSettingsMap[keys[i]].toString()}]!=[${_settings[keys[i]].toString()}]old");
        await _repository.setTableData(_tempUserSettings);

        _settings = _tempUserSettings.toJson();
        return _settings;
      }
    }
    return Map();
  }

  SettingBloc(UserSettingsRepository repository){
    this._repository = repository;
    _tempUserSettings = UserSettings();
    readCurrentSettings();
  }

  @override
  void dispose() {
    _adminController.close();
    _userIdController.close();
    _groupIdController.close();
    _enterAlertOnController.close();
    _closeAlertOnController.close();
    _beaconAlertOnController.close();
    _vibrationOnController.close();
    _loggingOnController.close();
    _startHourController.close();
    _startMinuteController.close();
    _startLunchHourController.close();
    _startLunchMinuteController.close();
    _endLunchHourController.close();
    _endLunchMinuteController.close();
    _endHourController.close();
    _endMinuteController.close();
    _closeDistanceMeterController.close();
    _beaconCloseDistanceMeterController.close();
    _beaconAlertOnController.close();
    _logIntervalSecController.close();
    _semiCloseLogIntervalSecController.close();
    _closeLogIntervalSecController.close();
    _enterLogIntervalSecController.close();
    _beaconLogIntervalSecController.close();
    _beaconNameListStringController.close();
  }
}