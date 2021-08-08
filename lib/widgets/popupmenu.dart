import 'package:flutter/material.dart';
import 'package:sftpmanager/constants/colors.dart';

class MyPopupMenuPage extends StatefulWidget {
  String title;

  // MyPopupMenuPage({Key? key}) : super(key: key);
  MyPopupMenuPage({required this.title});

  @override
  _MyPopupMenuPageState createState() => _MyPopupMenuPageState();
}

class _MyPopupMenuPageState extends State<MyPopupMenuPage> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PopupMenuButton<int>(
        offset: Offset(0, 40),
        color: default_background_color_highlight,
        icon: Icon(Icons.more_vert, color: default_text_color),
        elevation: 2,
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              enabled: false,
              child: Center(
                child: Text(
                  widget.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: default_text_color),
                ),
              ),
            ),
            PopupMenuItem(
              value: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Sync", style: TextStyle(color: default_text_color)),
                  IconButton(
                    icon: Icon(Icons.sync, color: default_text_color),
                    onPressed: () => {},
                  ),
                ],
              ),
            ),
          ];
        },
        onSelected: (value) {
          // print(value);
        },
      ),
    );
  }
}
