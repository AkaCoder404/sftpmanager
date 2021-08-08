import 'package:flutter/material.dart';
import 'package:sftpmanager/constants/colors.dart';
import 'package:sftpmanager/constants/functions.dart';

class MyAppBarPopUpMenuPage extends StatefulWidget {
  VoidCallback isSelected;

  MyAppBarPopUpMenuPage({required this.isSelected});
  // MyAppBarPopUpMenuPage({Key? key}) : super(key: key);

  @override
  _MyAppBarPopUpMenuPageState createState() => _MyAppBarPopUpMenuPageState();
}

class _MyAppBarPopUpMenuPageState extends State<MyAppBarPopUpMenuPage> {
  void manageState() {}
  @override
  Widget build(BuildContext context) {
    return Container(
      child: PopupMenuButton(
        color: default_background_color_highlight,
        icon: Icon(Icons.menu),
        offset: Offset(0, 40),
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem(
              value: 0,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Info", style: TextStyle(color: default_text_color)), Icon(Icons.info)],
                ),
              ),
            ),
            PopupMenuItem(
              value: 1,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Sync", style: TextStyle(color: default_text_color)), Icon(Icons.sync)],
                ),
              ),
            ),
            PopupMenuItem(
              value: 2,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Select", style: TextStyle(color: default_text_color)),
                    Icon(Icons.select_all),
                  ],
                ),
              ),
            ),
          ];
        },
        onSelected: (value) {
          switch (value) {
            case 1:
              break;
            case 2:
              widget.isSelected();
              break;
            default:
              break;
          }
        },
      ),
    );
  }
}
