import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sftpmanager/bloc/connection_event.dart';
import 'package:sftpmanager/constants/colors.dart';
import 'package:sftpmanager/db/connectiondb.dart';
import 'package:sftpmanager/models/connection.dart';
import 'package:sftpmanager/pages/connections_page.dart';
import 'package:sftpmanager/pages/settings_page.dart';

import 'bloc/connection_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.s
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConnectionBloc>(
      create: (context) => ConnectionBloc(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'SFTPManager'),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentPage = MyConnectionsPage();

  // permissions
  // permission
  late PermissionStatus _permissionStatus;

  // add connection form
  final _formKey = GlobalKey<FormState>();
  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _hostIpController = TextEditingController();
  TextEditingController _portController = TextEditingController();
  TextEditingController _pathController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    () async {
      _permissionStatus = await Permission.storage.status;

      if (_permissionStatus != PermissionStatus.granted) {
        PermissionStatus permissionStatus = await Permission.storage.request();
        setState(() {
          _permissionStatus = permissionStatus;
        });
      }
    }();

    super.initState();
  }

  // add new server
  void _createNewConnection() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: default_background_color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: IntrinsicHeight(
          child: Container(
            // height: 500,
          // padding: EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 10),
                Container(
                  color: default_background_color,
                  child: Text("SFTP Connection", style: TextStyle(color: default_text_color)),
                ),
                SizedBox(height: 10),
                Container(
                  color: default_background_color_highlight,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text("Display Name", style: TextStyle(color: default_text_color)),
                      ),
                      SizedBox(width: 30),
                      Expanded(
                        child: TextFormField(
                          controller: _displayNameController,
                          style: TextStyle(color: default_text_color),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Optional",
                              hintStyle: TextStyle(fontSize: 14, color: default_text_color)),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  color: default_background_color_highlight,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "Host/IP",
                          style: TextStyle(color: default_text_color),
                        ),
                      ),
                      SizedBox(width: 30),
                      Expanded(
                        child: TextFormField(
                          controller: _hostIpController,
                          style: TextStyle(color: default_text_color),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Required",
                              hintStyle: TextStyle(fontSize: 14, color: default_text_color)),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  color: default_background_color_highlight,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "Port",
                          style: TextStyle(color: default_text_color),
                        ),
                      ),
                      SizedBox(width: 30),
                      Expanded(
                        child: TextFormField(
                          controller: _portController,
                          style: TextStyle(color: default_text_color),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Default 22",
                              hintStyle: TextStyle(fontSize: 14, color: default_text_color)),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  color: default_background_color_highlight,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          "Path",
                          style: TextStyle(color: default_text_color),
                        ),
                      ),
                      SizedBox(width: 30),
                      Expanded(
                        child: TextFormField(
                          controller: _pathController,
                          style: TextStyle(color: default_text_color),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Optional",
                              hintStyle: TextStyle(fontSize: 14, color: default_text_color)),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  color: default_background_color,
                  child: Text(
                    "Account",
                    style: TextStyle(color: default_text_color),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  color: default_background_color_highlight,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text("Username", style: TextStyle(color: default_text_color)),
                      ),
                      SizedBox(width: 30),
                      Expanded(
                        child: TextFormField(
                          controller: _usernameController,
                          style: TextStyle(color: default_text_color),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Optional",
                              hintStyle: TextStyle(fontSize: 14, color: default_text_color)),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  color: default_background_color_highlight,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text("Password", style: TextStyle(color: default_text_color)),
                      ),
                      SizedBox(width: 30),
                      Expanded(
                        child: TextFormField(
                          controller: _passwordController,
                          style: TextStyle(color: default_text_color),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Optional",
                              hintStyle: TextStyle(fontSize: 14, color: default_text_color)),
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 3,
                    ),
                    RawMaterialButton(
                      onPressed: () {
                        setState(() {
                          _displayNameController.clear();
                          _hostIpController.clear();
                          _portController.clear();
                          _pathController.clear();
                          _usernameController.clear();
                          _passwordController.clear();
                        });
                      },
                      child: Text(
                        "Clear",
                        style: TextStyle(color: default_text_color),
                      ),
                      fillColor: Colors.blue,
                      elevation: 0,
                      splashColor: null,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    RawMaterialButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: default_text_color),
                      ),
                      fillColor: Colors.blue,
                      elevation: 0,
                      splashColor: null,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    RawMaterialButton(
                      fillColor: Colors.blue,
                      elevation: 0,
                      splashColor: null,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      onPressed: () {
                        // if form is valid
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          Connection connection = Connection(
                              displayName: _displayNameController.text,
                              hostIp: _hostIpController.text,
                              port: _portController.text,
                              path: _pathController.text,
                              username: _usernameController.text,
                              password: _passwordController.text);

                          ConnectionsDatabaseProvider.db.insert(connection).then(
                            (storedConnection) {
                              BlocProvider.of<ConnectionBloc>(context).add(AddConnectionEvent(storedConnection));
                            },
                          );

                          Navigator.of(context).pop();
                        }
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(color: default_text_color),
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: default_background_color_highlight,
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("SFTPManager", style: TextStyle(color: default_text_color)),
      ),
      body: PageStorage(bucket: bucket, child: currentPage),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        child: Icon(Icons.add),
        onPressed: _createNewConnection,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomAppBar(
        // shape: CircularNotchedRectangle(),
        color: default_background_color,
        // notchMargin: 10,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    onPressed: () {
                      setState(() {
                        currentPage = new MyConnectionsPage();
                      });
                    },
                    child: Icon(Icons.home, color: Colors.blue),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    onPressed: () {
                      setState(() {
                        currentPage = MySettingsPage();
                      });
                    },
                    child: Icon(Icons.settings, color: Colors.blue),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
