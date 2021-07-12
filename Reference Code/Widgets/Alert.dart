import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class AlertMessage {
  BuildContext context;
  String title;
  String message;

  AlertMessage({BuildContext context, String title, String message}) {
    this.context = context;
    this.title = title;
    this.message = message;
  }

  void getWidget() {
    Alert(context: context, title: title, desc: message, buttons: [
      DialogButton(
        child: Text('Okay'),
        onPressed: () {
          Navigator.pop(context);
        },
        color: Colors.red,
      ),
    ]).show();
  }
}
