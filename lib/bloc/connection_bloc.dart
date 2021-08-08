import 'dart:async';

import 'package:sftpmanager/bloc/connection_event.dart';
import 'package:sftpmanager/models/connection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, List<Connection>> {
  // ConnectionBloc(List<Connection> initialState) : super(initialState);

  // @override
  // List<Connection> get initialState => [];
  ConnectionBloc()
      : super(List<Connection>.filled(
            0,
            Connection(
                displayName: '',
                hostIp: '',
                password: '',
                path: '',
                port: '',
                username: '')));

  @override
  Stream<List<Connection>> mapEventToState(ConnectionEvent event) async* {
    if (event is SetConnectionEvent) {
      yield event.connectionList!;
    } else if (event is AddConnectionEvent) {
      List<Connection> newState = List.from(state);

      if (event.newConnection != null) {
        newState.add(event.newConnection!);
      }
      yield newState;
    } else if (event is DeleteConnectionEvent) {
      List<Connection> newState = List.from(state);
      newState.removeAt(event.connectionIndex!);
      yield newState;
    }
  }
}
