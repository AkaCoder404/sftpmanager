import 'dart:io';

// import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';

import 'package:flutter_pdfview/flutter_pdfview.dart';

import 'package:sftpmanager/constants/colors.dart';
import 'package:sftpmanager/constants/functions.dart';
// import 'package:ssh/ssh.dart';

class MyPDFPage extends StatefulWidget {
  final String serverPath;
  final String path;
  final String name;

  const MyPDFPage({required this.serverPath, required this.path, required this.name});
  @override
  _MyPDFPageState createState() => _MyPDFPageState();
}

class _MyPDFPageState extends State<MyPDFPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.serverPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: default_background_color,
        title: Text(widget.name),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
        ],
      ),
      backgroundColor: default_background_color_highlight,
      // body: PDFViewerScaffold(path: widget.path),
      body: Center(child: PDFView(filePath: widget.path)),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: default_background_color,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        items: [
          BottomNavigationBarItem(
            label: "home",
            icon: IconButton(
              icon: Icon(Icons.home, color: Colors.blue),
              onPressed: () => incompleteFunctionalitySnackbar(context, "incomplete"),
            ),
          ),
          BottomNavigationBarItem(
            label: "save",
            icon: IconButton(
              icon: Icon(Icons.save, color: Colors.blue),
              onPressed: () => incompleteFunctionalitySnackbar(context, "incomplete"),
            ),
          ),
          BottomNavigationBarItem(
            label: "delete",
            icon: IconButton(
              icon: Icon(Icons.delete, color: Colors.blue),
              onPressed: () => incompleteFunctionalitySnackbar(context, "incomplete"),
            ),
          ),
        ],
      ),
    );
  }
}
