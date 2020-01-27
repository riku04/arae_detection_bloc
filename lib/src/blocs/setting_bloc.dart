
import 'dart:async';

import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter_map_app/src/models/user_settings.dart';
import 'package:flutter_map_app/src/repository/user_settings_repository.dart';

class SettingBloc extends Bloc{
  Map<String,dynamic> prevSettings;
  Map<String,dynamic> settings;

  UserSettings userSettings;

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
    settings = Map.from(await UserSettingsRepository().getValues());
    prevSettings = Map.from(settings);

    userSettings.userId = (settings[UserSettings.USER_ID]);
    userSettings.groupId = (settings[UserSettings.GROUP_ID]);
    userSettings.admin = (settings[UserSettings.ADMIN]);
    userSettings.enterAlertOn = (settings[UserSettings.ENTER_ALERT_ON]);
    userSettings.closeAlertOn = (settings[UserSettings.CLOSE_ALERT_ON]);
    userSettings.beaconAlertOn = (settings[UserSettings.BEACON_ALERT_ON]);
    userSettings.vibrationOn = (settings[UserSettings.VIBRATION_ON]);
    userSettings.loggingOn = (settings[UserSettings.LOGGING_ON]);
    userSettings.startHour = (settings[UserSettings.START_HOUR]);
    userSettings.startMinute = (settings[UserSettings.START_MINUTE]);
    userSettings.startLunchHour = (settings[UserSettings.START_LUNCH_HOUR]);
    userSettings.startLunchMinute = (settings[UserSettings.START_LUNCH_MINUTE]);
    userSettings.endLunchHour = (settings[UserSettings.END_LUNCH_HOUR]);
    userSettings.endLunchMinute = (settings[UserSettings.END_LUNCH_MINUTE]);
    userSettings.endHour = (settings[UserSettings.END_HOUR]);
    userSettings.endMinute = (settings[UserSettings.END_MINUTE]);
    userSettings.closeDistanceMeter = (settings[UserSettings.CLOSE_DISTANCE_METER]);
    userSettings.beaconCloseDistanceMeter = (settings[UserSettings.BEACON_CLOSE_DISTANCE_METER]);
    userSettings.logIntervalSec = (settings[UserSettings.LOG_INTERVAL_SEC]);
    userSettings.semiCloseLogIntervalSec = (settings[UserSettings.SEMI_CLOSE_LOG_INTERVAL_SEC]);
    userSettings.closeLogIntervalSec = (settings[UserSettings.CLOSE_LOG_INTERVAL_SEC]);
    userSettings.enterLogIntervalSec = (settings[UserSettings.ENTER_LOG_INTERVAL_SEC]);
    userSettings.beaconLogIntervalSec = (settings[UserSettings.BEACON_LOG_INTERVAL_SEC]);
    userSettings.beaconNameListString = (settings[UserSettings.BEACON_NAME_LIST_STRING]);
    
    userId.add(settings[UserSettings.USER_ID]);
    groupId.add(settings[UserSettings.GROUP_ID]);
    admin.add(settings[UserSettings.ADMIN]);
    enterAlertOn.add(settings[UserSettings.ENTER_ALERT_ON]);
    closeAlertOn.add(settings[UserSettings.CLOSE_ALERT_ON]);
    beaconAlertOn.add(settings[UserSettings.BEACON_ALERT_ON]);
    vibrationOn.add(settings[UserSettings.VIBRATION_ON]);
    loggingOn.add(settings[UserSettings.LOGGING_ON]);
    startHour.add(settings[UserSettings.START_HOUR]);
    startMinute.add(settings[UserSettings.START_MINUTE]);
    startLunchHour.add(settings[UserSettings.START_LUNCH_HOUR]);
    startLunchMinute.add(settings[UserSettings.START_LUNCH_MINUTE]);
    endLunchHour.add(settings[UserSettings.END_LUNCH_HOUR]);
    endLunchMinute.add(settings[UserSettings.END_LUNCH_MINUTE]);
    endHour.add(settings[UserSettings.END_HOUR]);
    endMinute.add(settings[UserSettings.END_MINUTE]);
    closeDistanceMeter.add(settings[UserSettings.CLOSE_DISTANCE_METER]);
    beaconCloseDistanceMeter.add(settings[UserSettings.BEACON_CLOSE_DISTANCE_METER]);
    logIntervalSec.add(settings[UserSettings.LOG_INTERVAL_SEC]);
    semiCloseLogIntervalSec.add(settings[UserSettings.SEMI_CLOSE_LOG_INTERVAL_SEC]);
    closeLogIntervalSec.add(settings[UserSettings.CLOSE_LOG_INTERVAL_SEC]);
    enterLogIntervalSec.add(settings[UserSettings.ENTER_LOG_INTERVAL_SEC]);
    beaconLogIntervalSec.add(settings[UserSettings.BEACON_LOG_INTERVAL_SEC]);
    beaconNameListString.add(settings[UserSettings.BEACON_NAME_LIST_STRING]);

  }
  
  void save() async{

    UserSettingsRepository().setTable(userSettings);
//
//    settings.keys.forEach((key) {
//      if(settings[key]!=prevSettings[key]) {
//        print("changed:"+settings[key].toString());
//        UserSettingsRepository().setValue(key, settings[key]).then((_){
//          readCurrentSettings();
//        });
//      }
//    });
  }

  SettingBloc(){
    userSettings = UserSettings();
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