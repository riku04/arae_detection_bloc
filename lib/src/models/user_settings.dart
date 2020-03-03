

class UserSettings {

//  Map<String,dynamic> status = {
//    USER_ID : "user_0",
//    GROUP_ID : "group_0",
//    ADMIN : 0,
//    ENTER_ALERT_ON : 1,
//    CLOSE_ALERT_ON : 1,
//    BEACON_ALERT_ON : 1,
//    VIBRATION_ON : 1,
//    LOGGING_ON : 1,
//    START_HOUR : 9,
//    START_MINUTE : 0,
//    START_LUNCH_HOUR : 12,
//    START_LUNCH_MINUTE : 0,
//    END_LUNCH_HOUR : 13,
//    END_LUNCH_MINUTE : 0,
//    END_HOUR : 18,
//    END_MINUTE : 0,
//    CLOSE_DISTANCE_METER : 10,
//    BEACON_CLOSE_DISTANCE_METER : 10,
//    LOG_INTERVAL_SEC : 10,
//    SEMI_CLOSE_LOG_INTERVAL_SEC : 5,
//    CLOSE_LOG_INTERVAL_SEC : 3,
//    ENTER_LOG_INTERVAL_SEC : 3,
//    BEACON_LOG_INTERVAL_SEC : 3,
//    BEACON_NAME_LIST_STRING : '',
//  };

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
  static const String END_LUNCH_HOUR = 'END_LUNCH_HOUR';
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
  static const String BEACON_NAME_LIST_STRING = 'BEACON_NAME';

   String userId;
   String groupId;
   int admin;
   int enterAlertOn;
   int closeAlertOn;
   int beaconAlertOn;
   int vibrationOn;
   int loggingOn;
   int startHour;
   int startMinute;
   int startLunchHour;
   int startLunchMinute;
   int endLunchHour;
   int endLunchMinute;
   int endHour;
   int endMinute;
   int closeDistanceMeter;
   int beaconCloseDistanceMeter;
   int logIntervalSec;
   int semiCloseLogIntervalSec;
   int closeLogIntervalSec;
   int enterLogIntervalSec;
   int beaconLogIntervalSec;
   String beaconNameListString;

  UserSettings({
    this.userId = "user_default",
    this.groupId = "group_default",
    this.admin = 0,
    this.enterAlertOn = 1,
    this.closeAlertOn = 1,
    this.beaconAlertOn = 1,
    this.vibrationOn = 1,
    this.loggingOn = 1,
    this.startHour = 9,
    this.startMinute = 0,
    this.startLunchHour = 12,
    this.startLunchMinute = 0,
    this.endLunchHour = 13,
    this.endLunchMinute = 0,
    this.endHour = 18,
    this.endMinute = 0,
    this.closeDistanceMeter = 10,
    this.beaconCloseDistanceMeter = 10,
    this.logIntervalSec = 10,
    this.semiCloseLogIntervalSec = 10,
    this.closeLogIntervalSec = 5,
    this.enterLogIntervalSec = 3,
    this.beaconLogIntervalSec = 3,
    this.beaconNameListString = ""
  });

  UserSettings.toJson(Map<String, dynamic> json)
      : userId = json[USER_ID],
        groupId = json[GROUP_ID],
        admin = json[ADMIN],
        enterAlertOn = json[ENTER_ALERT_ON],
        closeAlertOn = json[CLOSE_ALERT_ON],
        beaconAlertOn = json[BEACON_ALERT_ON],
        vibrationOn = json[VIBRATION_ON],
        loggingOn = json[LOGGING_ON],
        startHour = json[START_HOUR],
        startMinute = json[START_MINUTE],
        startLunchHour = json[START_LUNCH_HOUR],
        startLunchMinute = json[START_LUNCH_MINUTE],
        endLunchHour = json[END_LUNCH_HOUR],
        endLunchMinute = json[END_LUNCH_MINUTE],
        endHour = json[END_HOUR],
        endMinute = json[END_MINUTE],
        closeDistanceMeter = json[CLOSE_DISTANCE_METER], 
        beaconCloseDistanceMeter = json[BEACON_CLOSE_DISTANCE_METER],
        logIntervalSec = json[LOG_INTERVAL_SEC],
        semiCloseLogIntervalSec = json[SEMI_CLOSE_LOG_INTERVAL_SEC],
        closeLogIntervalSec = json[CLOSE_LOG_INTERVAL_SEC],
        enterLogIntervalSec = json[ENTER_LOG_INTERVAL_SEC],
        beaconLogIntervalSec = json[BEACON_LOG_INTERVAL_SEC],
        beaconNameListString = json[BEACON_NAME_LIST_STRING];

  Map<String, dynamic> toJson() => {
        USER_ID:userId,
        GROUP_ID:groupId,
        ADMIN:admin,
        ENTER_ALERT_ON:enterAlertOn,
        CLOSE_ALERT_ON:closeAlertOn,
        BEACON_ALERT_ON:beaconAlertOn,
        VIBRATION_ON:vibrationOn,
        LOGGING_ON:loggingOn,
        START_HOUR:startHour,
        START_MINUTE:startMinute,
        START_LUNCH_HOUR:startLunchHour,
        START_LUNCH_MINUTE:startLunchMinute,
        END_LUNCH_HOUR:endLunchHour,
        END_LUNCH_MINUTE:endLunchMinute,
        END_HOUR:endHour,
        END_MINUTE:endMinute,
        CLOSE_DISTANCE_METER:closeDistanceMeter,
        BEACON_CLOSE_DISTANCE_METER:beaconCloseDistanceMeter,
        LOG_INTERVAL_SEC:logIntervalSec,
        SEMI_CLOSE_LOG_INTERVAL_SEC:semiCloseLogIntervalSec,
        CLOSE_LOG_INTERVAL_SEC:closeLogIntervalSec,
        ENTER_LOG_INTERVAL_SEC:enterLogIntervalSec,
        BEACON_LOG_INTERVAL_SEC:beaconLogIntervalSec,
        BEACON_NAME_LIST_STRING:beaconNameListString,
      };


}
