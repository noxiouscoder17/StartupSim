import 'package:flutter/material.dart';

class InvestCard {
  Function onPressed;
  double width, height;
  String title;
  Widget child;

  InvestCard({this.onPressed, this.width, this.height, this.title, this.child});

  Card getWidget() {
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
      child: Container(
        alignment: Alignment.center,
        width: width,
        height: height,
        child: child,
      ),
    );
  }
}
