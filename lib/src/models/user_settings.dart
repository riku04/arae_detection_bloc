class UserSettings {
  static const String USER_ID = "USER_ID";
  static const String GROUP_ID = "GROUP_ID";
  static const String ADMIN = "ADMIN";
  static const String ENTER_ALERT_ON = 'ENTER_ALERT_ON';
  static const String CLOSE_ALERT_ON = 'CLOSE_ALERT_ON';
  static const String BEACON_ALERT_ON = 'BEACON_ALERT_ON';
  static const String VIBRATION_ON = 'VIBRATION_ON';
  static const String LOGGING_ON = 'LOGGING_ON';
  static const String START_HOUR = 'START_HOUR';
  static const String START_MINUTE = 'START_MINUTE';
  static const String START_LUNCH_HOUR = 'START_LUNCH_HOUR';
  static const String START_LUNCH_MINUTE = 'START_LUNCH_MINUTE';
  static const String END_LUNCH_HOUR = 'END_LLUNCH_HOUR';
  static const String END_LUNCH_MINUTE = 'END_LUNCH_MINUTE';
  static const String END_HOUR = 'END_HOUR';
  static const String END_MINUTE = 'END_MINUTE';
  static const String CLOSE_DISTANCE_METER = 'CLOSE_DISTANCE_METER';
  static const String BEACON_CLOSE_DISTANCE_METER = 'BEACON_CLOSE_DISTANCE_METER';
  static const String LOG_INTERVAL_SEC = 'LOG_INTERVAL_SEC';
  static const String SEMI_CLOSE_LOG_INTERVAL_SEC = 'SEMI_CLOSE_LOG_INTERVAL_SEC';
  static const String CLOSE_LOG_INTERVAL_SEC = 'CLOSE_LOG_INTERVAL_SEC';
  static const String ENTER_LOG_INTERVAL_SEC = 'ENTER_LOG_INTERVAL_SEC';
  static const String BEACON_LOG_INTERVAL_SEC = 'BEACON_LOG_INTERVAL_SEC';
  static const String BEACON_NAME = 'BEACON_NAME';


  String _userId;
  String _groupId;
  bool _admin;
  bool _enterAlertOn;
  bool _closeAlertOn;
  bool _beaconAlertOn;
  bool _vibrationOn;
  bool _loggingOn;
  int _startHour;
  int _startMinute;
  int _startLunchHour;
  int _startLunchMinute;
  int _endLunchHour;
  int _endLunchMinute;
  int _endHour;
  int _endMinute;
  int _closeDistanceMeter;
  int _beaconCloseDistanceMeter;
  int _logIntervalSec;
  int _semiCloseLogIntervalSec;
  int _closeLogIntervalSec;
  int _enterLogIntervalSec;
  int _beaconLogIntervalSec;
  String _beaconNameListString;

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
      : _userId = json[USER_ID],
        _groupId = json[GROUP_ID],
        _admin = json[ADMIN],
        _enterAlertOn = json[ENTER_ALERT_ON],
        _closeAlertOn = json[CLOSE_ALERT_ON],
        _beaconAlertOn = json[BEACON_ALERT_ON],
        _vibrationOn = json[VIBRATION_ON],
        _loggingOn = json[LOGGING_ON],
        _startHour = json[START_HOUR],
        _startMinute = json[START_MINUTE],
        _startLunchHour = json[START_LUNCH_HOUR],
        _startLunchMinute = json[START_LUNCH_MINUTE],
        _endLunchHour = json[END_LUNCH_HOUR],
        _endLunchMinute = json[END_LUNCH_MINUTE],
        _endHour = json[END_HOUR],
        _endMinute = json[END_MINUTE],
        _closeDistanceMeter = json[CLOSE_DISTANCE_METER],
        _beaconCloseDistanceMeter = json[BEACON_CLOSE_DISTANCE_METER],
        _logIntervalSec = json[LOG_INTERVAL_SEC],
        _semiCloseLogIntervalSec = json[SEMI_CLOSE_LOG_INTERVAL_SEC],
        _closeLogIntervalSec = json[CLOSE_LOG_INTERVAL_SEC],
        _enterLogIntervalSec = json[ENTER_LOG_INTERVAL_SEC],
        _beaconLogIntervalSec = json[BEACON_LOG_INTERVAL_SEC],
        _beaconNameListString = json[BEACON_NAME];

  Map<String, dynamic> toJson() => {
        USER_ID: _userId,
        GROUP_ID: _groupId,
        ADMIN: _admin,
        ENTER_ALERT_ON: _enterAlertOn,
        CLOSE_ALERT_ON: _closeAlertOn,
        BEACON_ALERT_ON: _beaconAlertOn,
        VIBRATION_ON: _vibrationOn,
        LOGGING_ON: _loggingOn,
        START_HOUR: _startHour,
        START_MINUTE: _startMinute,
        START_LUNCH_HOUR: _startLunchHour,
        START_LUNCH_MINUTE: _startLunchMinute,
        END_LUNCH_HOUR: _endLunchHour,
        END_LUNCH_MINUTE: _endLunchMinute,
        END_HOUR: _endHour,
        END_MINUTE: _endMinute,
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
