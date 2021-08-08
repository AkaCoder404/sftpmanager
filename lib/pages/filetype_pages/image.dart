import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:sftpmanager/constants/colors.dart';
import 'package:sftpmanager/constants/functions.dart';

class MyPicturePage extends StatefulWidget {
  final List<String> images;
  final int currentPage;
  final String dir;

  const MyPicturePage({required this.images, required this.currentPage, required this.dir});
  // : super(key: key);

  @override
  _MyPicturePageState createState() => _MyPicturePageState();
}

class _MyPicturePageState extends State<MyPicturePage> {
  String _file = "0";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // print(widget.images);

    var length = widget.images[widget.currentPage].split("/").length;
    print(widget.images[widget.currentPage].split("/")[length - 1]);

    setState(() {
      // _file = widget.currentPage.toString();
      _file = widget.images[widget.currentPage].split("/")[length - 1];
    });
  }

  void _onPageViewChanged(int page) {
    // print(page.toString());
    print(widget.images[page]);
    var length = widget.images[page].split("/").length;

    setState(() {
      _file = widget.images[page].split("/")[length - 1];
    });
  }

  void _reload() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: default_background_color_highlight,
      appBar: AppBar(backgroundColor: default_background_color, title: Text(_file)),
      body: PageView(
        controller: new PageController(initialPage: widget.currentPage),
        onPageChanged: _onPageViewChanged,
        children: widget.images.map((f) {
          setState(() {
            imageCache!.clear();
            imageCache!.clearLiveImages();
          });
          return Image.file(File(f));
        }).toList(),
      ),
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
