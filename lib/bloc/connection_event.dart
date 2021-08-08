import 'package:sftpmanager/models/connection.dart';

abstract class ConnectionEvent {}

class SetConnectionEvent extends ConnectionEvent {
  List<Connection>? connectionList;
  SetConnectionEvent(List<Connection> connections) {
    connectionList = connections;
  }
}

class AddConnectionEvent extends ConnectionEvent {
  Connection? newConnection;

  AddConnectionEvent(Connection connection) {
    newConnection = connection;
  }
}

class DeleteConnectionEvent extends ConnectionEvent {
  int? connectionIndex;

  DeleteConnectionEvent(int index) {
    connectionIndex = index;
  }
}

class UpdateConnectionEvent extends ConnectionEvent {}
