import 'package:flutter/material.dart';

class ElevatedTextField {
  IconData icon;
  String label;
  bool obscureText;
  Function onSaved;

  ElevatedTextField(
      {IconData icon, String label, bool obscureText, Function onSaved}) {
    this.icon = icon;
    this.label = label;
    this.obscureText = obscureText;
    this.onSaved = onSaved;
  }

  Container getWidget() {
    return Container(
      child: TextFormField(
        onSaved: onSaved,
        obscureText: obscureText,
        maxLines: 1,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(70.0),
            borderSide: BorderSide(
              width: 1,
              color: Colors.red[400],
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(70.0),
            borderSide: BorderSide(
              color: Colors.red[400],
            ),
          ),
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: Colors.red[400],
          ),
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(70),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54.withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(4, 10),
          ),
        ],
      ),
    );
  }
}
