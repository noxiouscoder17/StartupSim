import 'package:flutter/material.dart';

class StockCard {
  double width, height;
  IconData icon;
  String title, subtitle;
  Function onPressed;
  StockCard(
      {this.width,
      this.height,
      this.title,
      this.icon,
      this.subtitle,
      this.onPressed});
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
        child: TextButton(
          onPressed: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: Colors.black,
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: width,
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
