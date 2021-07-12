import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:startupsim/Controller/NavigationController.dart';
import 'package:startupsim/Controller/ValidationController.dart';
import 'package:startupsim/Widgets/Alert.dart';
import 'package:startupsim/Widgets/SocialSignin.dart';
import 'package:startupsim/Widgets/Title.dart';
import 'package:startupsim/Widgets/CurvedContainer.dart';
import 'package:startupsim/Widgets/StadiumButton.dart';
import 'package:startupsim/Widgets/ElevatedTextField.dart';

class SigninPage extends StatefulWidget {
  static const String id = 'signinPage';
  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final formKey = GlobalKey<FormState>();
  String email, password;
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
                padding: const EdgeInsets.all(20.0),
                child: MyTitle(primary: 'Sign in', secondary: 'Welcome Back')
                    .getWidget(),
              ),
              Expanded(
                child: TopLeftCurvedContainer(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(right: 20, left: 20, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StadiumButton(
                                    onPressed: () {
                                      setState(() {
                                        NavigateTo().signinPage(context);
                                      });
                                    },
                                    text: 'Sign in',
                                    color: Colors.red[400],
                                    width: 120,
                                    height: 50)
                                .getWidget(),
                            SizedBox(
                              width: 10,
                            ),
                            StadiumButton(
                                    onPressed: () {
                                      setState(() {
                                        NavigateTo().signupPage(context);
                                      });
                                    },
                                    text: 'Sign up',
                                    color: Colors.red[400],
                                    width: 120,
                                    height: 50)
                                .getWidget(),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              ElevatedTextField(
                                      onSaved: (emailValue) {
                                        email = emailValue;
                                      },
                                      icon: Icons.email,
                                      label: 'Email',
                                      obscureText: false)
                                  .getWidget(),
                              SizedBox(
                                height: 5,
                              ),
                              ElevatedTextField(
                                      onSaved: (passwordValue) {
                                        password = passwordValue;
                                      },
                                      icon: Icons.vpn_key,
                                      label: 'Password',
                                      obscureText: true)
                                  .getWidget(),
                              SizedBox(
                                height: 5,
                              ),
                              TextButton(
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                ),
                                onPressed: () {
                                  setState(() {
                                    NavigateTo().forgotPasswordPage(context);
                                  });
                                },
                              ),
                              StadiumButton(
                                      onPressed: () {
                                        formKey.currentState.save();
                                        setState(() async {
                                          final user = Validation.signin(
                                            email: email,
                                            password: password,
                                          );
                                          await user.signin();
                                          if (await user.message != null) {
                                            AlertMessage(
                                              context: context,
                                              title: 'Error',
                                              message: user.message,
                                            ).getWidget();
                                          }
                                          if (user.isSignedIn()) {
                                            if (user.isVerified()) {
                                              NavigateTo().homePage(context);
                                            } else {
                                              user.sendEmailVerification();
                                              AlertMessage(
                                                context: context,
                                                title: 'Verify',
                                                message:
                                                    'Verify your email by clicking on the link in email to continue',
                                              ).getWidget();
                                            }
                                          }
                                        });
                                      },
                                      text: 'Sign in',
                                      color: Colors.red[400],
                                      width: 250,
                                      height: 50)
                                  .getWidget(),
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
                                    final googleUser = Validation();
                                    await googleUser.signInWithGoogle();
                                    await isSignedIn(googleUser);
                                  });
                                },
                              ).getWidget(),
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

  void isSignedIn(Validation googleUser) {
    if (googleUser.isSignedIn()) {
      NavigateTo().homePage(context);
    } else {
      isSignedIn(googleUser);
    }
  }
}
