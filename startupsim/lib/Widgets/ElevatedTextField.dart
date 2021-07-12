import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ElevatedTextField {
  IconData icon;
  String label;
  bool obscureText;
  Function onSaved;
  Function onFieldSubmitted = (value) {};
  var inputFormatter = [FilteringTextInputFormatter.singleLineFormatter];

  ElevatedTextField(
      {IconData icon, String label, bool obscureText, Function onSaved}) {
    this.icon = icon;
    this.label = label;
    this.obscureText = obscureText;
    this.onSaved = onSaved;
  }
  ElevatedTextField.special(
      {IconData icon,
      String label,
      bool obscureText,
      Function onSaved,
      final inputFormatter}) {
    this.icon = icon;
    this.label = label;
    this.obscureText = obscureText;
    this.onSaved = onSaved;
    this.inputFormatter = inputFormatter;
  }
  ElevatedTextField.search(
      {IconData icon,
      String label,
      bool obscureText,
      Function onSaved,
      Function onFieldSubmitted,
      final inputFormatter}) {
    this.icon = icon;
    this.label = label;
    this.obscureText = obscureText;
    this.onSaved = onSaved;
    this.onFieldSubmitted = onFieldSubmitted;
    this.inputFormatter = inputFormatter;
  }

  Container getWidget() {
    return Container(
      child: TextFormField(
        onFieldSubmitted: onFieldSubmitted,
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
        inputFormatters: inputFormatter,
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
