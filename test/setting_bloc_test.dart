
import 'package:flutter/cupertino.dart';
import 'package:flutter_map_app/src/blocs/setting_bloc.dart';
import 'package:flutter_map_app/src/mocks/mock_user_settings_repository.dart';
import 'package:flutter_map_app/src/models/user_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  group("SettingBloc", () {
    SettingBloc bloc;
    MockUserSettingsRepository repository;
    setUp(() {
      repository = MockUserSettingsRepository();
      bloc = SettingBloc(repository);
    });

    test("repository initialized confirmation", () async{
      Map<String,dynamic> map;
      map = await repository.getTableData();
      bool isInitialized = true;
      map.keys.forEach((key) {
        if(map[key] != UserSettings().toJson()[key]){
          isInitialized = false;
        }
      });
      expect(isInitialized,true);
    });
    

    test("set data",() async {
      Map<String, dynamic> settings = UserSettings().toJson();

      settings.update(UserSettings.USER_ID, (value) => "user_id_0");
      settings.update(UserSettings.GROUP_ID, (value) => "group_id_0");
      settings.update(UserSettings.ADMIN, (value) => 1);
      settings.update(UserSettings.ENTER_ALERT_ON, (value) => 0);
      settings.update(UserSettings.CLOSE_ALERT_ON, (value) => 0);
      settings.update(UserSettings.BEACON_ALERT_ON, (value) => 0);
      settings.update(UserSettings.VIBRATION_ON, (value) => 0);
      settings.update(UserSettings.LOGGING_ON, (value) => 0);
      settings.update(UserSettings.START_HOUR, (value) => 10);
      settings.update(UserSettings.START_MINUTE, (value) => 30);
      settings.update(UserSettings.START_LUNCH_HOUR, (value) => 11);
      settings.update(UserSettings.START_LUNCH_MINUTE, (value) => 30);
      settings.update(UserSettings.END_LUNCH_HOUR, (value) => 12);
      settings.update(UserSettings.END_LUNCH_MINUTE, (value) => 30);
      settings.update(UserSettings.END_HOUR, (value) => 13);
      settings.update(UserSettings.END_MINUTE, (value) => 30);
      settings.update(UserSettings.CLOSE_DISTANCE_METER, (value) => 15);
      settings.update(UserSettings.BEACON_CLOSE_DISTANCE_METER, (value) => 15);
      settings.update(UserSettings.LOG_INTERVAL_SEC, (value) => 1);
      settings.update(UserSettings.SEMI_CLOSE_LOG_INTERVAL_SEC, (value) => 1);
      settings.update(UserSettings.CLOSE_LOG_INTERVAL_SEC, (value) => 1);
      settings.update(UserSettings.ENTER_LOG_INTERVAL_SEC, (value) => 1);
      settings.update(UserSettings.BEACON_LOG_INTERVAL_SEC, (value) => 1);
      settings.update(UserSettings.BEACON_NAME_LIST_STRING, (value) => "beacon0,beacon1,beacon2");

      bloc.setTempUserId(settings[UserSettings.USER_ID]);
      bloc.setTempGroupId(settings[UserSettings.GROUP_ID]);
      bloc.setTempAdmin(settings[UserSettings.ADMIN]);
      bloc.setTempEnterAlertOn(settings[UserSettings.ENTER_ALERT_ON]);
      bloc.setTempCloseAlertOn(settings[UserSettings.CLOSE_ALERT_ON]);
      bloc.setTempBeaconAlertOn(settings[UserSettings.BEACON_ALERT_ON]);
      bloc.setTempVibrationOn(settings[UserSettings.VIBRATION_ON]);
      bloc.setTempLoggingOn(settings[UserSettings.LOGGING_ON]);
      bloc.setTempStartHour(settings[UserSettings.START_HOUR]);
      bloc.setTempStartMinute(settings[UserSettings.START_MINUTE]);
      bloc.setTempStartLunchHour(settings[UserSettings.START_LUNCH_HOUR]);
      bloc.setTempStartLunchMinute(settings[UserSettings.START_LUNCH_MINUTE]);
      bloc.setTempEndLunchHour(settings[UserSettings.END_LUNCH_HOUR]);
      bloc.setTempEndLunchMinute(settings[UserSettings.END_LUNCH_MINUTE]);
      bloc.setTempEndHour(settings[UserSettings.END_HOUR]);
      bloc.setTempEndMinute(settings[UserSettings.END_MINUTE]);
      bloc.setTempCloseDistanceMeter(settings[UserSettings.CLOSE_DISTANCE_METER]);
      bloc.setTempBeaconCloseDistanceMeter(settings[UserSettings.BEACON_CLOSE_DISTANCE_METER]);
      bloc.setTempLogIntervalSec(settings[UserSettings.LOG_INTERVAL_SEC]);
      bloc.setTempSemiCloseLogIntervalSec(settings[UserSettings.SEMI_CLOSE_LOG_INTERVAL_SEC]);
      bloc.setTempCloseLogIntervalSec(settings[UserSettings.CLOSE_LOG_INTERVAL_SEC]);
      bloc.setTempEnterLogIntervalSec(settings[UserSettings.ENTER_LOG_INTERVAL_SEC]);
      bloc.setTempBeaconLogIntervalSec(settings[UserSettings.BEACON_LOG_INTERVAL_SEC]);
      bloc.setTempBeaconNameListString(settings[UserSettings.BEACON_NAME_LIST_STRING]);

      await bloc.save();

      Map<String,dynamic> map = await repository.getTableData();
      bool hasSame = true;
      map.keys.forEach((key) {
        if(map[key]!=settings[key]){
          print("$key:${map[key].toString()}!=${settings[key].toString()}");
          hasSame = false;
        }
      });
      expect(hasSame, true);
    });
  });
}
