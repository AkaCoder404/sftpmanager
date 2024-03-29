import 'dart:io';
import 'dart:math';
import 'dart:ui';

// import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sftpmanager/constants/colors.dart';
import 'package:sftpmanager/constants/functions.dart';
import 'package:sftpmanager/models/connection.dart';
import 'package:sftpmanager/pages/filetype_pages/image.dart';
import 'package:sftpmanager/pages/filetype_pages/pdf.dart';
import 'package:sftpmanager/widgets/appbar_popupmenu.dart';
import 'package:sftpmanager/widgets/popupmenu.dart';

// import 'package:ssh/ssh.dart';
import 'package:dartssh2/dartssh2.dart';

class MyConnectionPage extends StatefulWidget {
  Connection connection;
  // MyConnectionPage({Key? key}) : super(key: key);
  MyConnectionPage({required this.connection});

  @override
  _MyConnectionPageState createState() => _MyConnectionPageState();
}

class _MyConnectionPageState extends State<MyConnectionPage> with SingleTickerProviderStateMixin {
  // file management
  List _array = [];
  String _currentDir = "./";
  String _shell = "";

  // filetype
  List<String> _imageList = [];
  String _pathName = "FIC";
  String pdfPath = "";
  String pdfName = "";

  // select
  bool _select = false;
  List<bool> _selectedValues = [];

  // floating action button animation
  bool isOpened = false;
  AnimationController? _animationController;
  Animation<Color>? _buttonColor;
  Animation<double>? _animationIcon;
  Animation<double>? _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  // listview
  bool isListView = true;
  String sortType = "Name";
  bool isAscending = true;

  // client
  var _client;

  // download
  double _downloadProgress = 0;

  // appbar popupmenu
  void isSelected() {
    setState(() {
      _select = !_select;
    });
  }

  @override
  void initState() {
    // TODO: implement initState

    setState(() {
      // _client = new SSHClient(
      //     host: widget.connection.hostIp,
      //     port: int.parse(widget.connection.port),
      //     username: widget.connection.username,
      //     passwordOrKey: widget.connection.password);
      // _client = new SSHClient(
      //   host: widget.connection.hostIp,
      //   port: int.parse(widget.connection.port),
      //   username: widget.connection.username,
      //   passwordOrKey: widget.connection.password);
    });

    _makeSTFPRequest();

    // fab animation
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });

    _animationIcon = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController!);
    _buttonColor = ColorTween(begin: Colors.blue, end: Colors.red)
            .animate(CurvedAnimation(parent: _animationController!, curve: Interval(0.00, 1.00, curve: Curves.linear)))
        as Animation<Color>?;

    _translateButton = Tween<double>(begin: _fabHeight, end: -14.0)
        .animate(CurvedAnimation(parent: _animationController!, curve: Interval(0.0, 0.75, curve: _curve)));

    super.initState();
  }

  void _makeSTFPRequest() async {
    setState(() {
      _currentDir = "./";
    });

    try {
      String result = await _client.connect();
      if (result == "session_connected") {
        result = await _client.connectSFTP();
        if (result == "sftp_connected") {
          var array = await _client.sftpLs();

          setState(() {
            _shell = result;
            _array = array;
            // _array.sort();
            _array.sort((a, b) => a["filename"].toLowerCase().compareTo(b["filename"].toLowerCase()));

            _selectedValues = new List<bool>.generate(array.length, (i) => false);
          });

          // disconnect
          print(await _client.disconnectSFTP());
          _client.disconnect();
        }
      }
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
  }

  void _cdDir() async {
    print("cd " + _currentDir);
    String result = await _client.connect();
    if (result == "session_connected") {
      result = await _client.connectSFTP();
      if (result == "sftp_connected") {
        var array = await _client.sftpLs(_currentDir);
        List<String> dir = _currentDir.split("/");
        String currentPath = dir[dir.length - 2];
        // String currentPath = (_currentDir.split("/"))[_currentDir.length - 1];
        // print("currentPaht: " + currentPath);
        setState(() {
          // array.sort((a, b) => a["filename"].toLowerCase().compareTo(b["filename"].toLowerCase()));
          _array = array;
          _array.sort((a, b) => a["filename"].toLowerCase().compareTo(b["filename"].toLowerCase()));
          _pathName = currentPath == "." ? "FIC" : currentPath;
        });
      }
      await _client.disconnectSFTP();
      _client.disconnect();
    }
  }

  void _cdBackDir() async {
    var dirList = _currentDir.split("/");
    _currentDir = dirList.getRange(0, dirList.length - 2).toList().join("/") + "/";

    setState(() {
      _currentDir = _currentDir;
    });

    print("going back to:" + _currentDir);

    _cdDir();
  }

  Future<String> _downloadImages(int currentPage, String fileName) async {
    // temporary download cache
    Directory tempDir = await getTemporaryDirectory();
    Directory(tempDir.path + "/images").createSync(recursive: true);
    String tempPath = tempDir.path + "/images";
    // print("downloadDir: " + tempPath);

    List<String> images = [];

    try {
      String result = await _client.connect();
      if (result == "session_connected") {
        result = await _client.connectSFTP();
        if (result == "sftp_connected") {
          int count = 0;
          int selectPage = 0;
          for (var element in _array) {
            // print(element["filename"]);

            var type = lookupMimeType(element["filename"]);

            if (type == "image/jpeg") {
              if (element["filename"] == fileName) {
                selectPage = count;
              }
              count++;

              // print("download file: " + element["filename"]);
              // print("server filepath " + _currentDir + element["filename"]);

              var filePath = await _client.sftpDownload(
                path: _currentDir + element["filename"],
                toPath: tempPath,
                callback: (progress) async {
                  // print(progress);
                  setState(() {
                    _downloadProgress = progress / 100.0;
                  });
                },
              );
              // print("device filepath: " + filePath);
              images.add(filePath);
            }
          }

          // print(images);
          // print(images[selectPage]);

          setState(() {
            images.sort((a, b) => int.parse(a.split("/")[a.split("/").length - 1].split(".")[0])
                .compareTo(int.parse(b.split("/")[b.split("/").length - 1].split(".")[0])));
            _imageList = images;
            _downloadProgress = 0.0;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => new MyPicturePage(images: _imageList, currentPage: selectPage, dir: _currentDir),
            ),
          );

          print(await _client.disconnectSFTP());
          _client.disconnect();
        }
      }
    } on PlatformException catch (e) {
      print('Error: ${e.code}\nError Message: ${e.message}');
    }
    return "success";
  }

  void _onSearch(String value) {}

  void _clearCache() async {}

  Future<String> _downloadPDF(String pdfName) async {
    Directory tempDir = await getTemporaryDirectory();
    Directory(tempDir.path + "/pdf").createSync();
    String tempPath = tempDir.path + "/pdf";
    String result = await _client.connect();
    if (result == "session_connected") {
      result = await _client.connectSFTP();
      if (result == "sftp_connected") {
        var filepath = await _client.sftpDownload(
          path: _currentDir + pdfName,
          toPath: tempPath,
          callback: (progress) {
            // print(progress);
            setState(() {
              _downloadProgress = progress.toDouble() / 100;
            });
          },
        );

        setState(() {
          pdfPath = filepath;
          pdfName = pdfName;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => new MyPDFPage(serverPath: _currentDir + pdfName, path: pdfPath, name: pdfName),
          ),
        );

        setState(() {
          _downloadProgress = 0;
        });
        print(await _client.disconnectSFTP());
        _client.disconnect();
        return "success";
      }
    }

    return "success";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: default_background_color_highlight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: default_background_color,
        title: Text(
          _pathName,
          style: TextStyle(color: default_text_color),
        ),
        centerTitle: true,
        leading: _currentDir == "./"
            ? IconButton(
                icon: Icon(Icons.home),
                onPressed: () {},
              )
            : BackButton(
                onPressed: _cdBackDir,
              ),
        actions: <Widget>[MyAppBarPopUpMenuPage(isSelected: isSelected)],
      ),
      body: Column(
        children: [
          Container(
            color: default_background_color,
            child: Container(
              // color: Colors.white,
              height: 40,
              margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
              decoration: BoxDecoration(color: default_background_color_highlight),
              child: TextField(
                textAlignVertical: TextAlignVertical.bottom,
                onChanged: _onSearch,
                style: TextStyle(color: default_text_color),
                decoration: InputDecoration(
                    hintStyle: TextStyle(color: default_text_color),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.blue,
                    ),
                    border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10)),
                    hintText: 'Enter a search term'),
              ),
            ),
          ),
          LinearProgressIndicator(
            value: _downloadProgress,
            backgroundColor: default_background_color,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          color: default_background_color,
                          height: 30,
                          child: Row(
                            children: [
                              MaterialButton(
                                  child: Row(children: [
                                    Text("Name", style: TextStyle(color: default_text_color)),
                                    sortType == "Name"
                                        ? isAscending
                                            ? Icon(Icons.arrow_upward, size: 15, color: default_text_color)
                                            : Icon(Icons.arrow_downward, size: 15, color: default_text_color)
                                        : Text(""),
                                  ]),
                                  padding: EdgeInsets.symmetric(horizontal: 2),
                                  onPressed: () {
                                    setState(() {
                                      if (sortType != "Name") {
                                        isAscending = true;
                                      } else {
                                        isAscending = !isAscending;
                                      }
                                      sortType = "Name";
                                    });
                                  }),
                              MaterialButton(
                                  child: Row(children: [
                                    Text("Date", style: TextStyle(color: default_text_color)),
                                    sortType == "Date"
                                        ? isAscending
                                            ? Icon(Icons.arrow_upward, size: 15, color: default_text_color)
                                            : Icon(Icons.arrow_downward, size: 15, color: default_text_color)
                                        : Text(""),
                                  ]),
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  onPressed: () {
                                    setState(() {
                                      if (sortType != "Date") {
                                        isAscending = true;
                                      } else {
                                        isAscending = !isAscending;
                                      }
                                      sortType = "Date";
                                    });
                                  }),
                              MaterialButton(
                                  child: Row(children: [
                                    Text("Type", style: TextStyle(color: default_text_color)),
                                    sortType == "Type"
                                        ? isAscending
                                            ? Icon(Icons.arrow_upward, size: 15, color: default_text_color)
                                            : Icon(Icons.arrow_downward, size: 15, color: default_text_color)
                                        : Text(""),
                                  ]),
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  onPressed: () {
                                    setState(() {
                                      if (sortType != "Type") {
                                        isAscending = true;
                                      } else {
                                        isAscending = !isAscending;
                                      }
                                      sortType = "Type";
                                    });
                                  }),
                              MaterialButton(
                                  child: Row(children: [
                                    Text("Size", style: TextStyle(color: default_text_color)),
                                    sortType == "Size"
                                        ? isAscending
                                            ? Icon(Icons.arrow_upward, size: 15, color: default_text_color)
                                            : Icon(Icons.arrow_downward, size: 15, color: default_text_color)
                                        : Text(""),
                                  ]),
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  onPressed: () {
                                    setState(() {
                                      if (sortType != "Size") {
                                        isAscending = true;
                                      } else {
                                        isAscending = !isAscending;
                                      }
                                      sortType = "Size";
                                    });
                                  }),
                            ],
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isListView = !isListView;
                                });
                              },
                              child: isListView
                                  ? Icon(
                                      Icons.list,
                                      color: Colors.blue,
                                    )
                                  : Icon(Icons.apps, color: Colors.blue)),
                        )
                      ],
                    ),
                  ),
                  _array.length > 0
                      ? isListView
                          ? ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _array.length,
                              separatorBuilder: (BuildContext context, int index) {
                                return _array[index]["filename"][0] != "." ? Divider(height: 1) : Container();
                              },
                              itemBuilder: (context, index) {
                                return _array[index]["filename"][0] != "."
                                    ? Container(
                                        height: 50,
                                        child: GestureDetector(
                                          onTap: () async {
                                            print(_array[index]);
                                            if (_array[index]["isDirectory"]) {
                                              setState(() {
                                                _currentDir = _currentDir + _array[index]["filename"] + "/";
                                              });
                                              _cdDir();
                                            } else {
                                              // if a file
                                              var type = lookupMimeType(_array[index]["filename"]);

                                              switch (type) {
                                                case "image/jpeg":
                                                  {
                                                    var result = _downloadImages(index, _array[index]["filename"]);
                                                    // print(result);
                                                  }
                                                  break;
                                                case "application/pdf":
                                                  {
                                                    var result = await _downloadPDF(_array[index]["filename"]);
                                                    // print("result: " + result);
                                                  }
                                                  break;
                                                default:
                                                  {
                                                    print("file type not supported");
                                                  }
                                              }
                                            }
                                          },
                                          child: Card(
                                            margin: EdgeInsets.all(0),
                                            color: default_background_color,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(0),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                _select
                                                    ? Checkbox(
                                                        value: _selectedValues[index],
                                                        onChanged: (bool? value) {
                                                          setState(() {
                                                            _selectedValues[index] = !_selectedValues[index];
                                                          });
                                                        })
                                                    : Container(child: SizedBox(width: 10)),
                                                _array[index]["isDirectory"]
                                                    ? Icon(
                                                        Icons.folder,
                                                        color: Colors.blue,
                                                      )
                                                    : Icon(Icons.file_present, color: default_text_color),
                                                SizedBox(
                                                  width: 18,
                                                ),
                                                Expanded(
                                                    // flex: 100,
                                                    child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
                                                    Expanded(
                                                      flex: 85,
                                                      child: Text(
                                                        _array[index]["filename"],
                                                        // overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(color: default_text_color),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 15,
                                                        child: MyPopupMenuPage(title: _array[index]["filename"])
                                                        // child:
                                                        )
                                                  ],
                                                ))
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container();
                              },
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                              ),
                              itemCount: _array.length,
                              itemBuilder: (BuildContext context, int index) {
                                return _array[index]["filename"][0] != "."
                                    ? Container(
                                        child: Card(
                                          color: Colors.amber,
                                          child: Column(
                                            children: [
                                              _array[index]["isDirectory"]
                                                  ? Icon(Icons.folder)
                                                  : Icon(Icons.file_present)
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(height: 0, width: 0);
                              })
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Text(
                                "No Files",
                                style: TextStyle(color: default_text_color),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          )
        ],
      ),
      floatingActionButton: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Transform(transform: Matrix4.translationValues(0.0, _translateButton!.value * 3, 0.0), child: buttonAdd()),
            Transform(transform: Matrix4.translationValues(0.0, _translateButton!.value * 2, 0.0), child: buttonFile()),
            Transform(
              transform: Matrix4.translationValues(0.0, _translateButton!.value, 0.0),
              child: buttonFolder(),
            ),
            buttonToggle(),
            SizedBox(height: 30)
          ],
        ),
      ),
      // // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomAppBar(
          // shape: CircularNotchedRectangle(),
          color: default_background_color,
          notchMargin: 10,
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
                        Navigator.of(context).pop();
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
                        incompleteFunctionalitySnackbar(context, "history incomplete");
                      },
                      child: Icon(Icons.history, color: Colors.blue),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }

  // Button Widgets
  // Widget buttonAdd() {
  //   return Container(
  //     child: FloatingActionButton(
  //       elevation: 0,
  //       heroTag: "buttonAdd",
  //       onPressed: () {
  //         print("add");
  //       },
  //       tooltip: "Add",
  //       child: Icon(Icons.add),
  //     ),
  //   );
  // }

  Widget buttonFile() {
    return Container(
      child: FloatingActionButton(
        elevation: 0,
        heroTag: "buttonFile",
        onPressed: () {
          print("file");
        },
        tooltip: "File",
        child: Icon(Icons.file_copy),
      ),
    );
  }

  Widget buttonFolder() {
    return Container(
      child: FloatingActionButton(
        elevation: 0,
        heroTag: "buttonFolder",
        onPressed: () {
          print("folder");
        },
        tooltip: "Folder",
        child: Icon(Icons.folder),
      ),
    );
  }

  Widget buttonToggle() {
    return Container(
      child: FloatingActionButton(
        heroTag: "buttonToggle",
        elevation: 0,
        backgroundColor: _buttonColor!.value,
        onPressed: animate,
        tooltip: "Toggle",
        child: AnimatedIcon(icon: AnimatedIcons.menu_close, progress: _animationIcon!),
      ),
    );
  }

  animate() {
    if (!isOpened)
      _animationController!.forward();
    else
      _animationController!.reverse();
    isOpened = !isOpened;
  }
}
