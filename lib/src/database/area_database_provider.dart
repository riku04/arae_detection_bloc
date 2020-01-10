import 'package:flutter_map_app/src/database/database_provider.dart';
import 'package:flutter_map_app/src/resources/constants.dart';
import 'package:sqflite/sqflite.dart';

class AreaDatabaseProvider extends DatabaseProvider{
  @override
  String get databaseName => "area_db.db";

  @override
  String get tableName => Constants.DEFAULT_AREA_TABLE;

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