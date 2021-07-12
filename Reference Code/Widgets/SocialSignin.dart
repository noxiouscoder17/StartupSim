import 'package:flutter/material.dart';

class GoogleButton {
  Function onPressed;
  String text;
  Color color;
  double width;
  double height;

  GoogleButton(
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
      child: Container(
        width: width - 30,
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('images/google.png'),
              width: 30,
              height: 30,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: 30,
            )
          ],
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
