import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startupsim/Controllers/UserController.dart';
import 'package:startupsim/Views/RegisterPage.dart';
import 'package:startupsim/Views/SigninPage.dart';
import 'package:startupsim/Widgets/Alert.dart';
import 'package:startupsim/Widgets/CurvedContainer.dart';
import 'package:startupsim/Widgets/ElevatedTextField.dart';
import 'package:startupsim/Widgets/StadiumButton.dart';
import 'package:startupsim/Widgets/Title.dart';

class SignupPage extends StatefulWidget {
  static const String id = 'signupPage';
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String email, password, confirmPassword;

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
                  primary: 'Sign Up',
                  secondary: 'Welcome',
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
                              onPressed: () {
                                Navigator.pushNamed(context, SigninPage.id);
                              },
                              text: 'Sign in',
                              color: Colors.red[400],
                              width: 120,
                              height: 50,
                            ).getWidget(),
                            SizedBox(
                              width: 10,
                            ),
                            StadiumButton(
                              onPressed: () {},
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
                              ElevatedTextField(
                                onSaved: (confirmPasswordValue) {
                                  confirmPassword = confirmPasswordValue;
                                },
                                icon: Icons.vpn_key,
                                label: 'Confirm Password',
                                obscureText: true,
                              ).getWidget(),
                              SizedBox(
                                height: 20,
                              ),
                              StadiumButton(
                                onPressed: () {
                                  _formKey.currentState.save();
                                  setState(() async {
                                    final user = await UserController.signUp(
                                      email: email,
                                      password: password,
                                      confirmPassword: confirmPassword,
                                    );
                                    await user.signUp();
                                    if (user.message != null) {
                                      AlertMessage(
                                        context: context,
                                        title: 'Error',
                                        message: user.message,
                                      ).getWidget();
                                    }
                                    if (user.currentUser() != null) {
                                      if (user.currentUser().emailVerified) {
                                        Navigator.pop(context);
                                        Navigator.pushNamed(
                                            context, RegisterPage.id);
                                      } else {
                                        user
                                            .currentUser()
                                            .sendEmailVerification();
                                        AlertMessage(
                                          context: context,
                                          title: 'Verify',
                                          message:
                                              'Verify your email by clicking link in email to continue',
                                        ).getWidget();
                                        user.signOut();
                                      }
                                    }
                                  });
                                },
                                text: 'Sign up',
                                color: Colors.red[400],
                                width: 250,
                                height: 50,
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
}
