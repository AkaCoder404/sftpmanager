import 'package:flutter/material.dart';
import 'package:sftpmanager/constants/colors.dart';

class MySettingsPage extends StatefulWidget {
  MySettingsPage({Key? key}) : super(key: key);

  @override
  _MySettingsPageState createState() => _MySettingsPageState();
}

class _MySettingsPageState extends State<MySettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        Container(
          height: 30,
          child: Row(
            children: [
              Icon(Icons.settings, color: default_text_color),
              Text("SETTINGS", style: TextStyle(color: default_text_color)),
            ],
          ),
        ),
      ],
    );
  }
}
