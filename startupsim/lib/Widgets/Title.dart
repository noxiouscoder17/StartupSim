import 'package:flutter/material.dart';

class MyTitle {
  String primary;
  String secondary;

  MyTitle({String primary, String secondary}) {
    this.primary = primary;
    this.secondary = secondary;
  }

  Row getWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              primary,
              style: TextStyle(fontSize: 45, color: Colors.white),
            ),
            Text(
              secondary,
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.all(0),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black54.withOpacity(0.25),
                spreadRadius: 10,
                blurRadius: 14,
                offset: Offset(10, 0),
              ),
            ],
          ),
          child: Image(
            width: 100,
            height: 100,
            image: AssetImage('images/startupsim.png'),
          ),
        )
      ],
    );
  }
}
