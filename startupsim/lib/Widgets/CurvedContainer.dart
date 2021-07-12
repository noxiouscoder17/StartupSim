import 'package:flutter/material.dart';

class TopLeftCurvedContainer {
  Widget child;
  Color color;

  TopLeftCurvedContainer({Widget child, Color color}) {
    this.child = child;
    if (color != null) {
      this.color = color;
    } else {
      this.color = Colors.white;
    }
  }

  Container getWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 50),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.elliptical(200, 60),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54.withOpacity(0.25),
            spreadRadius: 10,
            blurRadius: 14,
            offset: Offset(10, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}
