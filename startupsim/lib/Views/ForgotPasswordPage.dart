import 'dart:math';

import 'package:flutter/material.dart';
import 'package:startupsim/Controllers/UserController.dart';
import 'package:startupsim/Views/SigninPage.dart';
import 'package:startupsim/Widgets/Alert.dart';
import 'package:startupsim/Widgets/CurvedContainer.dart';
import 'package:startupsim/Widgets/ElevatedTextField.dart';
import 'package:startupsim/Widgets/StadiumButton.dart';
import 'package:startupsim/Widgets/Title.dart';

class ForgotPasswordPage extends StatefulWidget {
  static const String id = 'forgotPasswordPage';
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String email;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          padding: EdgeInsets.only(top: 30),
          width: double.infinity,
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
                padding: const EdgeInsets.all(20),
                child: MyTitle(
                  primary: 'Forgot\nPassword',
                  secondary: '',
                ).getWidget(),
              ),
              Expanded(
                child: TopLeftCurvedContainer(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      right: 20,
                      left: 20,
                      bottom: 10,
                      top: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: 300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Don\'t worry, enter your email and we\'ll send you a reset link',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              )
                            ],
                          ),
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
                                height: 25,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  StadiumButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pushNamed(
                                        context,
                                        SigninPage.id,
                                      );
                                    },
                                    text: 'Cancel',
                                    color: Colors.red[400],
                                    width: 120,
                                    height: 50,
                                  ).getWidget(),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  StadiumButton(
                                    onPressed: () {
                                      _formKey.currentState.save();
                                      setState(() async {
                                        final user =
                                            await UserController.forgotPassword(
                                          email: email,
                                        );
                                        await user.forgotPassword();
                                        if (user.message != null) {
                                          AlertMessage(
                                            context: context,
                                            title: 'Error',
                                            message: user.message,
                                          ).getWidget();
                                        } else {
                                          AlertMessage(
                                            context: context,
                                            title: 'Success',
                                            message:
                                                'Password reset link has been send to you email',
                                          ).getWidget();
                                        }
                                      });
                                    },
                                    text: 'Send Link',
                                    color: Colors.red[400],
                                    width: 120,
                                    height: 50,
                                  ).getWidget(),
                                ],
                              )
                            ],
                          ),
                        )
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
}
