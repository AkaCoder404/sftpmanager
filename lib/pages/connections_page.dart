import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sftpmanager/bloc/connection_bloc.dart';
import 'package:sftpmanager/bloc/connection_event.dart';
import 'package:sftpmanager/connection.dart';
import 'package:sftpmanager/constants/colors.dart';
import 'package:sftpmanager/constants/functions.dart';
import 'package:sftpmanager/db/connectiondb.dart';
import 'package:sftpmanager/models/connection.dart';
import 'package:ssh/ssh.dart';

class MyConnectionsPage extends StatefulWidget {
  MyConnectionsPage({Key? key}) : super(key: key);

  @override
  _MyConnectionsPageState createState() => _MyConnectionsPageState();
}

class _MyConnectionsPageState extends State<MyConnectionsPage> {
  @override
  void initState() {
    _refreshConnectionList();
    super.initState();
  }

  @override
  void dispose() {}

  // listview connections
  void _refreshConnectionList() {
    ConnectionsDatabaseProvider.db.getConnections().then((connectionList) {
      BlocProvider.of<ConnectionBloc>(context).add(SetConnectionEvent(connectionList));
    });
  }

  // connect to server and redirect to dir
  void _connect(Connection connection) async {
    var client = new SSHClient(
        host: connection.hostIp,
        port: int.parse(connection.port),
        username: connection.username,
        passwordOrKey: connection.password);

    try {
      String result;
      result = await client.connect();
      print(result);
      if (result == "session_connected") {
        Navigator.push(context, MaterialPageRoute(builder: (context) => new MyConnectionPage(connection: connection)));
      }
      // } else {
      //   // showDialog(
      //   //     context: context, builder: (BuildContext context) => Dialog(backgroundColor: default_background_color));
      // }
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
      showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
          backgroundColor: default_background_color,
          child: Container(
            height: 200,
            child: Center(
              child: Text(
                "Error Message: " + e.message!,
                style: TextStyle(color: default_text_color),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(height: 10),
      Container(
        height: 30,
        child: Row(
          children: [
            Icon(Icons.lock, color: default_text_color),
            Text("CONNECTIONS", style: TextStyle(color: default_text_color)),
          ],
        ),
      ),
      SizedBox(height: 5),
      Expanded(
        child: Container(
          child: BlocProvider<ConnectionBloc>(
            create: (_) => ConnectionBloc(),
            child: BlocConsumer<ConnectionBloc, List<Connection>>(
              bloc: BlocProvider.of<ConnectionBloc>(context),
              listener: (BuildContext context, connectionList) {},
              builder: (context, connectionList) {
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: connectionList.length,
                  separatorBuilder: (BuildContext context, int index) => new Divider(height: 1),
                  // physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      color: default_background_color,
                      child: Slidable(
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        child: ListTile(
                          leading: Icon(Icons.connected_tv),
                          title: Text(
                            connectionList[index].displayName,
                            style: TextStyle(color: default_text_color),
                          ),
                          onTap: () {
                            _connect(connectionList[index]);
                          },
                        ),
                        secondaryActions: <Widget>[
                          IconSlideAction(
                              caption: 'Edit',
                              color: Colors.blue,
                              icon: Icons.edit,
                              onTap: () => incompleteFunctionalitySnackbar(context, "edit incomplete")),
                          IconSlideAction(
                            caption: 'Delete',
                            color: Colors.indigo,
                            icon: Icons.delete,
                            onTap: () {
                              ConnectionsDatabaseProvider.db.delete(connectionList[index].id!).then((_) {
                                _refreshConnectionList();
                                // BlocProvider.of<ConnectionBloc>(context)
                                //     .add(DeleteConnectionEvent(index));
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    ]);
  }
}
