import 'package:flutter/material.dart';

class TopLeftCurvedContainer {
  Widget child;

  TopLeftCurvedContainer({Widget child}) {
    this.child = child;
  }

  Container getWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 50),
      decoration: BoxDecoration(
        color: Colors.white,
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
