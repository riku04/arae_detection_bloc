class UserSettings {
  String _userId = "user";
  String _groupId = "group";
  bool _admin = false;
  bool _enterAlertOn = true;
  bool _closeAlertOn = true;
  bool _beaconAlertOn = true;
  bool _vibrationOn = true;
  bool _loggingOn = true;
  int _startHour = 9;
  int _startMinute = 0;
  int _startLunchHour = 12;
  int _startLunchMinute = 0;
  int _endLunchHour = 13;
  int _endLunchMinute = 0;
  int _endHour = 18;
  int _endMinute = 0;
  int _closeDistanceMeter = 10;
  int _beaconCloseDistanceMeter = 10;
  int _logIntervalSec = 10;
  int _semiCloseLogIntervalSec = 10;
  int _closeLogIntervalSec = 5;
  int _enterLogIntervalSec = 3;
  int _beaconLogIntervalSec = 3;
  String _beaconNameListString = "";

  UserSettings() {
    _userId = "user";
    _groupId = "group";
    _admin = false;
    _enterAlertOn = true;
    _beaconAlertOn = true;
    _vibrationOn = true;
    _loggingOn = true;
    _startHour = 9;
    _startMinute = 0;
    _startLunchHour = 12;
    _startLunchMinute = 0;
    _endLunchHour = 13;
    _endLunchMinute = 0;
    _endHour = 18;
    _endMinute = 0;
    _closeDistanceMeter = 10;
    _beaconCloseDistanceMeter = 10;
    _logIntervalSec = 10;
    _semiCloseLogIntervalSec = 10;
    _closeLogIntervalSec = 5;
    _enterLogIntervalSec = 3;
    _beaconLogIntervalSec = 3;
    _beaconNameListString = "";
  }

  UserSettings.toJson(Map<String, dynamic> json)
      : _userId = json['USER_ID'],
        _groupId = json['GROUP_ID'],
        _admin = json['ADMIN'],
        _enterAlertOn = json['ENTER_ALERT_ON'],
        _closeAlertOn = json['CLOSE_ALERT_ON'],
        _beaconAlertOn = json['BEACON_ALERT_ON'],
        _vibrationOn = json['VIBRATION_ON'],
        _loggingOn = json['LOGGING_ON'],
        _startHour = json['START_HOUR'],
        _startMinute = json['START_MINUTE'],
        _startLunchHour = json['START_LUNCH_HOUR'],
        _startLunchMinute = json['START_LUNCH_MINUTE'],
        _endLunchHour = json['END_LLUNCH_HOUR'],
        _endLunchMinute = json['END_LUNCH_MINUTE'],
        _endHour = json['END_HOUR'],
        _endMinute = json['END_MINUTE'],
        _closeDistanceMeter = json['CLOSE_DISTANCE_METER'],
        _beaconCloseDistanceMeter = json['BEACON_CLOSE_DISTANCE_METER'],
        _logIntervalSec = json['LOG_INTERVAL_SEC'],
        _semiCloseLogIntervalSec = json['SEMI_CLOSE_LOG_INTERVAL_SEC'],
        _closeLogIntervalSec = json['CLOSE_LOG_INTERVAL_SEC'],
        _enterLogIntervalSec = json['ENTER_LOG_INTERVAL_SEC'],
        _beaconLogIntervalSec = json['BEACON_LOG_INTERVAL_SEC'],
        _beaconNameListString = json['BEACON_NAME'];

  Map<String, dynamic> toJson() => {
        'USER_ID': _userId,
        'GROUP_ID': _groupId,
        'ADMIN': _admin,
        'ENTER_ALERT_ON': _enterAlertOn,
        'CLOSE_ALERT_ON': _closeAlertOn,
        'BEACON_ALERT_ON': _beaconAlertOn,
        'VIBRATION_ON': _vibrationOn,
        'LOGGING_ON': _loggingOn,
        'START_HOUR': _startHour,
        'START_MINUTE': _startMinute,
        'START_LUNCH_HOUR': _startLunchHour,
        'START_LUNCH_MINUTE': _startLunchMinute,
        'END_LLUNCH_HOUR': _endLunchHour,
        'END_LUNCH_MINUTE': _endLunchMinute,
        'END_HOUR': _endHour,
        'END_MINUTE': _endMinute,
        'CLOSE_DISTANCE_METER': _closeDistanceMeter,
        'BEACON_CLOSE_DISTANCE_METER': _beaconCloseDistanceMeter,
        'LOG_INTERVAL_SEC': _logIntervalSec,
        'SEMI_CLOSE_LOG_INTERVAL_SEC': _semiCloseLogIntervalSec,
        'CLOSE_LOG_INTERVAL_SEC': _closeLogIntervalSec,
        'ENTER_LOG_INTERVAL_SEC': _enterLogIntervalSec,
        'BEACON_LOG_INTERVAL_SEC': _beaconLogIntervalSec,
        'BEACON_NAME': _beaconNameListString,
      };

  String stringJoiner(List<String> list) {
    String string = "";
    list.forEach((name) {
      string += name + ",";
    });
    string = string.substring(0, string.length - 1);
    return string;
  }
}
