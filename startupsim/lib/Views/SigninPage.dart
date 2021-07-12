import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startupsim/Controllers/DataController.dart';
import 'package:startupsim/Controllers/UserController.dart';
import 'package:startupsim/Models/models.dart';
import 'package:startupsim/Views/ForgotPasswordPage.dart';
import 'package:startupsim/Views/HomePage.dart';
import 'package:startupsim/Views/RegisterPage.dart';
import 'package:startupsim/Views/SignupPage.dart';
import 'package:startupsim/Widgets/Alert.dart';
import 'package:startupsim/Widgets/CurvedContainer.dart';
import 'package:startupsim/Widgets/ElevatedTextField.dart';
import 'package:startupsim/Widgets/SocialSignin.dart';
import 'package:startupsim/Widgets/StadiumButton.dart';
import 'package:startupsim/Widgets/Title.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SigninPage extends StatefulWidget {
  static const String id = 'signinPage';
  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _formKey = GlobalKey<FormState>();
  String email, password;
  DataController dataController = DataController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          padding: EdgeInsets.only(top: 30),
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.red[900],
                Colors.red[700],
                Colors.red[400],
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 70,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: MyTitle(
                  primary: 'Sign In',
                  secondary: 'Welcome Back',
                ).getWidget(),
              ),
              Expanded(
                child: TopLeftCurvedContainer(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      right: 20,
                      left: 20,
                      bottom: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StadiumButton(
                              onPressed: () {},
                              text: 'Sign in',
                              color: Colors.red[400],
                              width: 120,
                              height: 50,
                            ).getWidget(),
                            SizedBox(
                              width: 10,
                            ),
                            StadiumButton(
                              onPressed: () {
                                Navigator.pushNamed(context, SignupPage.id);
                              },
                              text: 'Sign Up',
                              color: Colors.red[400],
                              width: 120,
                              height: 50,
                            ).getWidget(),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              ElevatedTextField(
                                onSaved: (emailValue) {
                                  email = emailValue;
                                },
                                icon: Icons.email,
                                label: 'Email',
                                obscureText: false,
                              ).getWidget(),
                              SizedBox(
                                height: 5,
                              ),
                              ElevatedTextField(
                                onSaved: (passwordValue) {
                                  password = passwordValue;
                                },
                                icon: Icons.vpn_key,
                                label: 'Password',
                                obscureText: true,
                              ).getWidget(),
                              SizedBox(
                                height: 5,
                              ),
                              TextButton(
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    ForgotPasswordPage.id,
                                  );
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              StadiumButton(
                                onPressed: () {
                                  _formKey.currentState.save();
                                  setState(() async {
                                    final user = UserController.signIn(
                                      email: email,
                                      password: password,
                                    );
                                    await user.signIn();
                                    if (user.message != null) {
                                      AlertMessage(
                                        context: context,
                                        title: 'Error',
                                        message: user.message,
                                      ).getWidget();
                                    }
                                    if (user.currentUser() != null) {
                                      if (user.currentUser().emailVerified) {
                                        await ifUserExist();
                                        if (dataController.userExists) {
                                          await fetchUserData();
                                        }
                                        navigate();
                                      } else {
                                        user
                                            .currentUser()
                                            .sendEmailVerification();
                                        AlertMessage(
                                          context: context,
                                          title: 'Verify',
                                          message:
                                              'Verify your email by clicking on the link in the mail to continue',
                                        ).getWidget();
                                        user.signOut();
                                      }
                                    }
                                  });
                                },
                                text: 'Sign in',
                                color: Colors.red[400],
                                width: 250,
                                height: 50,
                              ).getWidget(),
                              SizedBox(
                                height: 20,
                              ),
                              GoogleButton(
                                text: 'Sign in With Google',
                                color: Colors.white,
                                width: 250,
                                height: 50,
                                onPressed: () {
                                  setState(() async {
                                    final googleUser = UserController();
                                    await googleUser.signInWithGoogle();
                                    await ifUserExist();
                                    if (await dataController.userExists) {
                                      await fetchUserData();
                                    }
                                    await checkSignIn();
                                  });
                                },
                              ).getWidget(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).getWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void checkSignIn() {
    setState(() {
      if (UserController().currentUser() != null) {
        navigate();
      } else {
        checkSignIn();
      }
    });
  }

  void navigate() {
    setState(() {
      if (dataController.userExists != null) {
        if (dataController.userExists) {
          if (dataController.userData['companyName'] != null) {
            Navigator.pop(context);
            Navigator.pushNamed(context, HomePage.id);
          } else {
            Navigator.pop(context);
            Navigator.pushNamed(context, RegisterPage.id);
          }
        } else {
          Navigator.pop(context);
          Navigator.pushNamed(context, RegisterPage.id);
        }
      }
    });
  }

  void fetchUserData() async {
    await dataController.fetchUserData();
  }

  void ifUserExist() async {
    await dataController.ifUserDataExists();
  }
}
