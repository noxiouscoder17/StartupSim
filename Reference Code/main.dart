import 'package:flutter/material.dart';
import 'package:startupsim/Controller/ValidationController.dart';
import 'package:startupsim/Interface/HomePage.dart';
import 'package:startupsim/Interface/SigninPage.dart';
import 'package:startupsim/Interface/SignupPage.dart';
import 'package:startupsim/Interface/ForgotPasswordPage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(StartupSim());
}

class StartupSim extends StatefulWidget {
  @override
  _StartupSimState createState() => _StartupSimState();
}

class _StartupSimState extends State<StartupSim> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: SignupPage.id,
      routes: {
        HomePage.id: (context) => HomePage(),
        ForgotPasswordPage.id: (context) => ForgotPasswordPage(),
        SigninPage.id: (context) => SigninPage(),
        SignupPage.id: (context) => SignupPage(),
      },
    );
  }
}
