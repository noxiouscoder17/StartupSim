import 'package:flutter/material.dart';

class TaskCard {
  String name;
  String type;
  String eta;
  Color color;
  Function onPressed;

  TaskCard({this.name, this.type, this.eta, this.color, this.onPressed});

  Card getWidget() {
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.only(top: 15, bottom: 5, right: 20, left: 20),
        alignment: Alignment.center,
        width: 250,
        height: 100,
        child: Column(
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${eta}',
                  style: TextStyle(fontSize: 17),
                ),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
