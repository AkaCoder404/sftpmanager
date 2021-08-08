import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sftpmanager/constants/colors.dart';

GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey();

void incompleteFunctionalitySnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 3,
      duration: Duration(milliseconds: 800),
      backgroundColor: Colors.blue,
      content: Text(message, style: TextStyle(color: default_text_color)));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //
  // _scaffoldMessengerKey.currentState!.showSnackBar(snackBar);
}
