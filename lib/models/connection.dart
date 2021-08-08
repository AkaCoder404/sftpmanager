import 'package:sftpmanager/db/connectiondb.dart';

class Connection {
  int? id;
  late String displayName;
  late String hostIp;
  late String port;
  late String path;
  late String username;
  late String password;

  Connection({
    required this.displayName,
    required this.hostIp,
    required this.port,
    required this.path,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      ConnectionsDatabaseProvider.COLUMN_DISPLAY_NAME: displayName,
      ConnectionsDatabaseProvider.COLUMN_HOST_IP: hostIp,
      ConnectionsDatabaseProvider.COLUMN_PATH: path,
      ConnectionsDatabaseProvider.COLUMN_PORT: port,
      ConnectionsDatabaseProvider.COLUMN_USERNAME: username,
      ConnectionsDatabaseProvider.COLUMN_PASSWORD: password
    };

    if (id != null) {
      map[ConnectionsDatabaseProvider.COLUMN_ID] = id;
    }

    return map;
  }

  Connection.fromMap(Map<String, dynamic> map) {
    id = map[ConnectionsDatabaseProvider.COLUMN_ID];
    displayName = map[ConnectionsDatabaseProvider.COLUMN_DISPLAY_NAME];
    hostIp = map[ConnectionsDatabaseProvider.COLUMN_HOST_IP];
    port = map[ConnectionsDatabaseProvider.COLUMN_PORT];
    path = map[ConnectionsDatabaseProvider.COLUMN_PATH];
    username = map[ConnectionsDatabaseProvider.COLUMN_USERNAME];
    password = map[ConnectionsDatabaseProvider.COLUMN_PASSWORD];
  }
}
