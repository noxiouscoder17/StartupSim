import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:startupsim/Views/Accounts.dart';
import 'package:startupsim/Views/CampaignsPage.dart';
import 'package:startupsim/Views/FinancesPage.dart';
import 'package:startupsim/Views/ForgotPasswordPage.dart';
import 'package:startupsim/Views/HomePage.dart';
import 'package:startupsim/Views/OperationsPage.dart';
import 'package:startupsim/Views/RegisterPage.dart';
import 'package:startupsim/Views/SigninPage.dart';
import 'package:startupsim/Views/SignupPage.dart';
import 'package:startupsim/Views/TaskPage.dart';

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
      initialRoute: SigninPage.id,
      routes: {
        SignupPage.id: (context) => SignupPage(),
        SigninPage.id: (context) => SigninPage(),
        ForgotPasswordPage.id: (context) => ForgotPasswordPage(),
        RegisterPage.id: (context) => RegisterPage(),
        HomePage.id: (context) => HomePage(),
        AccountPage.id: (context) => AccountPage(),
        OperationsPage.id: (context) => OperationsPage(),
        FinancesPage.id: (context) => FinancesPage(),
        CampaignsPage.id: (context) => CampaignsPage(),
        TaskPage.id: (context) => TaskPage(),
      },
    );
  }
}
