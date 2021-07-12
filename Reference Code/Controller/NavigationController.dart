import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:startupsim/Interface/ForgotPasswordPage.dart';
import 'package:startupsim/Interface/HomePage.dart';
import 'package:startupsim/Interface/SigninPage.dart';
import 'package:startupsim/Interface/SignupPage.dart';

class NavigateTo {
  NavigateTo();

  void homePage(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushNamed(context, HomePage.id);
  }

  void signinPage(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushNamed(context, SigninPage.id);
  }

  void signupPage(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushNamed(context, SignupPage.id);
  }

  void forgotPasswordPage(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushNamed(context, ForgotPasswordPage.id);
  }
}
