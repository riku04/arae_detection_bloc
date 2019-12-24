import 'package:flutter_map_app/src/database/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class AreaDatabaseProvider extends DatabaseProvider{
  String areaName;

  AreaDatabaseProvider(String areaName){
    this.areaName = areaName;
  }

  @override
  String get databaseName => "area_db.db";

  @override
  String get tableName => areaName;

  @override
  createDatabase(Database db, int version) => db.execute(
    """
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            points TEXT
          )
        """,
  );
}