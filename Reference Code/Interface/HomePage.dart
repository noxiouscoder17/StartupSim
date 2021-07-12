import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:startupsim/Controller/FirestoreController.dart';
import 'package:startupsim/Controller/NavigationController.dart';
import 'package:startupsim/Controller/ValidationController.dart';

class HomePage extends StatefulWidget {
  static const String id = 'homePage';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Validation user = Validation();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text('HomePage'),
          actions: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  user.signOut();
                  NavigateTo().signinPage(context);
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Center(
              child: Text(
                user.user.email,
              ),
            ),
            Center(
              child: ElevatedButton(
                child: Text("Test"),
                onPressed: () {
                  setState(() {
                    FireStore().test();
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
