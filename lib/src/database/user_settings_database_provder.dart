import 'package:flutter_map_app/src/database/database_provider.dart';
import 'package:flutter_map_app/src/resources/constants.dart';
import 'package:sqflite/sqflite.dart';

class UserSettingsDatabaseProvider extends DatabaseProvider {
  @override
  String get databaseName => Constants.USER_SETTING_DATABASE_NAME;

  @override
  String get tableName => Constants.DEFAULT_USER_SETTING_TABLE;

  @override
  createDatabase(Database db, int version) => db.execute(
        """
          CREATE TABLE $tableName(
          USER_ID TEXT DEFAULT user_0,                    
          GROUP_ID TEXT DEFAULT group_0,                  
          ADMIN INTEGER DEFAULT 0,                       
          ENTER_ALERT_ON INTEGER DEFAULT 1,       
          CLOSE_ALERT_ON INTEGER DEFAULT 1,       
          BEACON_ALERT_ON INTEGER DEFAULT 1,     
          VIBRATION_ON INTEGER DEFAULT 1,          
          LOGGING_ON INTEGER DEFAULT 1,                 
          START_HOUR INTEGER DEFAULT 9,              
          START_MINUTE INTEGER DEFAULT 0,          
          START_LUNCH_HOUR INTEGER DEFAULT 12,   
          START_LUNCH_MINUTE INTEGER DEFAULT 0,
          END_LLUNCH_HOUR INTEGER DEFAULT 13,      
          END_LUNCH_MINUTE INTEGER DEFAULT 0,   
          END_HOUR INTEGER DEFAULT 18,                  
          END_MINUTE INTEGER DEFAULT 0,              
          CLOSE_DISTANCE_METER INTEGER DEFAULT 10,
          BEACON_CLOSE_DISTANCE_METER INTEGER DEFAULT 10,
          LOG_INTERVAL_SEC INTEGER DEFAULT 10,
          SEMI_CLOSE_LOG_INTERVAL_SEC INTEGER DEFAULT 5,
          CLOSE_LOG_INTERVAL_SEC INTEGER DEFAULT 3,
          ENTER_LOG_INTERVAL_SEC INTEGER DEFAULT 3,
          BEACON_LOG_INTERVAL_SEC INTEGER DEFAULT 3,
          BEACON_NAME TEXT DEFAULT beacon
        )
        """,
      );
}

//"""
//          CREATE TABLE $tableName(
//          id INTEGER PRIMARY KEY AUTOINCREMENT,
//          USER_ID TEXT DEFAULT user_0,
//          GROUP_ID TEXT DEFAULT group_0,
//          ADMIN INTEGER DEFAULT 0,
//          ENTER_ALERT_ON INTEGER DEFAULT 1,
//          CLOSE_ALERT_ON INTEGER DEFAULT 1,
//          BEACON_ALERT_ON INTEGER DEFAULT 1,
//          VIBRATION_ON INTEGER DEFAULT 1,
//          LOGGING_ON INTEGER DEFAULT 1,
//          START_HOUR INTEGER DEFAULT 9,
//          START_MINUTE INTEGER DEFAULT 0,
//          START_LUNCH_HOUR INTEGER DEFAULT 12,
//          START_LUNCH_MINUTE INTEGER DEFAULT 0,
//          END_LLUNCH_HOUR INTEGER DEFAULT 13,
//          END_LUNCH_MINUTE INTEGER DEFAULT 0,
//          END_HOUR INTEGER DEFAULT 18,
//          END_MINUTE INTEGER DEFAULT 0,
//          CLOSE_DISTANCE_METER INTEGER DEFAULT 10,
//          BEACON_CLOSE_DISTANCE_METER INTEGER DEFAULT 10,
//          LOG_INTERVAL_SEC INTEGER DEFAULT 10,
//          SEMI_CLOSE_LOG_INTERVAL_SEC INTEGER DEFAULT 5,
//          CLOSE_LOG_INTERVAL_SEC INTEGER DEFAULT 3,
//          ENTER_LOG_INTERVAL_SEC INTEGER DEFAULT 3,
//          BEACON_LOG_INTERVAL_SEC INTEGER DEFAULT 3,
//          BEACON_NAME TEXT DEFAULT beacon
//        )
//        """,
