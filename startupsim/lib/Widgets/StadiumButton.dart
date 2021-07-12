import 'package:flutter/material.dart';

class StadiumButton {
  Function onPressed;
  String text;
  Color color;
  double width;
  double height;

  StadiumButton(
      {Function onPressed,
      String text,
      Color color,
      double width,
      double height}) {
    this.onPressed = onPressed;
    this.text = text;
    this.color = color;
    this.width = width;
    this.height = height;
  }

  ElevatedButton getWidget() {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: color,
        shape: StadiumBorder(),
        minimumSize: Size(width, height),
        elevation: 10,
      ),
    );
  }
}
