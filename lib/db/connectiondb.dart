import 'package:sftpmanager/models/connection.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ConnectionsDatabaseProvider {
  static const String TABLE_CONNECTION = "connection";
  static const String COLUMN_ID = "id";
  static const String COLUMN_DISPLAY_NAME = "display_name";
  static const String COLUMN_HOST_IP = "host_ip";
  static const String COLUMN_PORT = "port";
  static const String COLUMN_PATH = "path";
  static const String COLUMN_USERNAME = "username";
  static const String COLUMN_PASSWORD = "password";

  ConnectionsDatabaseProvider._();
  static final ConnectionsDatabaseProvider db = ConnectionsDatabaseProvider._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await createDatabase();
    return _database!;
  }

  Future<Database> createDatabase() async {
    print("create database");
    String dbPath = await getDatabasesPath();
    return await openDatabase(
      join(dbPath, 'connectionDB.db'),
      version: 1,
      onCreate: (Database database, int version) async {
        print("creating food table");
        String sql = "CREATE TABLE $TABLE_CONNECTION ("
            "$COLUMN_ID INTEGER PRIMARY KEY,"
            "$COLUMN_DISPLAY_NAME TEXT,"
            "$COLUMN_HOST_IP TEXT,"
            "$COLUMN_PORT TEXT,"
            "$COLUMN_PATH TEXT,"
            "$COLUMN_USERNAME TEXT,"
            "$COLUMN_PASSWORD TEXT"
            ")";
        await database.execute(sql);
      },
    );
  }

  Future<List<Connection>> getConnections() async {
    final db = await database;
    var connections = await db.query(TABLE_CONNECTION, columns: [
      COLUMN_ID,
      COLUMN_DISPLAY_NAME,
      COLUMN_HOST_IP,
      COLUMN_PORT,
      COLUMN_PATH,
      COLUMN_USERNAME,
      COLUMN_PASSWORD
    ]);

    List<Connection> connectionsList = [];

    connections.forEach((element) {
      Connection connection = Connection.fromMap(element);
      connectionsList.add(connection);
    });

    return connectionsList;
  }

  Future<Connection> insert(Connection connection) async {
    final db = await database;
    connection.id = await db.insert(TABLE_CONNECTION, connection.toMap());
    return connection;
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(TABLE_CONNECTION, where: "id = ?", whereArgs: [id]);
  }

  Future<int> update(Connection connection) async {
    final db = await database;
    return await db.update(TABLE_CONNECTION, connection.toMap(),
        where: "id = ?", whereArgs: [connection.id]);
  }
}
