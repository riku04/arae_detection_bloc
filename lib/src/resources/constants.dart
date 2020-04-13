import 'dart:ffi';

class Constants {
  static const String AREA_DATABASE_NAME = "area.db";
  static const String DEFAULT_AREA_TABLE = "area0";
  static const String USER_SETTING_DATABASE_NAME = "user_settings_000.db";
  static const String DEFAULT_USER_SETTING_TABLE = "user_settings_000";

  static const int ALPHA_MASK = 0x20000000;

  static const int SCAN_TIMEOUT = 15;
  static const int CONNECTION_TIMEOUT = 10;
  static const String defaultServiceUUID = "a851d584-5a3c-4f6b-9547-eda40ecf0ed8";
  static const String defaultCharacteristicUUID = "b851d584-5a3c-4f6b-9547-eda40ecf0ed8";
  static const num SEND_TYPE_AREA = 0x01;
  static const num SEND_TYPE_SETTINGS = 0x02;
  static const num SEND_END = 0x99;

  static const int OUTSIDE = 0;
  static const int CLOSE = 1;
  static const int INSIDE = 2;

  static const int LOG_PLAY_STOP = 0;
  static const int LOG_PLAY_START = 10;
  static const int LOG_PLAY_SPEED_1x = 1;
  static const int LOG_PLAY_SPEED_2x = 2;
  static const int LOG_PLAY_SPEED_4x = 4;
  static const int LOG_PLAY_SPEED_MINUS_1x = -1;
  static const int LOG_PLAY_SPEED_MINUS_2x = -2;
  static const int LOG_PLAY_SPEED_MINUS_4x = -4;
}