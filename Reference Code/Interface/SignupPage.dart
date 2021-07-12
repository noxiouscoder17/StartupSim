import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startupsim/Controller/ValidationController.dart';
import 'package:startupsim/Widgets/SocialSignin.dart';
import 'package:startupsim/Widgets/Title.dart';
import 'package:startupsim/Widgets/CurvedContainer.dart';
import 'package:startupsim/Widgets/StadiumButton.dart';
import 'package:startupsim/Widgets/ElevatedTextField.dart';
import 'package:startupsim/Controller/NavigationController.dart';
import 'package:startupsim/Widgets/Alert.dart';

class SignupPage extends StatefulWidget {
  static const String id = 'signupPage';
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String name;
  String email;
  String password;
  String confirmPassword;

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
                child: MyTitle(primary: 'Sign up', secondary: 'Welcome')
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
                        key: _formKey,
                        child: Column(
                          children: [
                            ElevatedTextField(
                                    onSaved: (nameValue) {
                                      name = nameValue;
                                    },
                                    icon: Icons.person,
                                    label: 'Name',
                                    obscureText: false)
                                .getWidget(),
                            SizedBox(
                              height: 5,
                            ),
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
                            ElevatedTextField(
                                    onSaved: (confirmPasswordValue) {
                                      confirmPassword = confirmPasswordValue;
                                    },
                                    icon: Icons.vpn_key,
                                    label: 'Confirm Password',
                                    obscureText: true)
                                .getWidget(),
                            SizedBox(
                              height: 10,
                            ),
                            StadiumButton(
                                    onPressed: () {
                                      _formKey.currentState.save();
                                      setState(() async {
                                        final user = await Validation.signup(
                                          email: email,
                                          password: password,
                                          confirmPassword: confirmPassword,
                                        );
                                        user.name = name;
                                        await user.signup();
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
                                            print('Not Verified');
                                          }
                                        }
                                      });
                                    },
                                    text: 'Sign up',
                                    color: Colors.red[400],
                                    width: 250,
                                    height: 50)
                                .getWidget(),
                          ],
                        ),
                      )
                    ],
                  ),
                )).getWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
