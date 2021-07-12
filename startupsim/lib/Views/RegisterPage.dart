import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:startupsim/Controllers/DataController.dart';
import 'package:startupsim/Controllers/UserController.dart';
import 'package:startupsim/Models/models.dart';
import 'package:startupsim/Views/HomePage.dart';
import 'package:startupsim/Views/SigninPage.dart';
import 'package:startupsim/Widgets/Alert.dart';
import 'package:startupsim/Widgets/CurvedContainer.dart';
import 'package:startupsim/Widgets/ElevatedTextField.dart';
import 'package:startupsim/Widgets/StadiumButton.dart';
import 'package:startupsim/Widgets/Title.dart';

class RegisterPage extends StatefulWidget {
  static const String id = 'registerPage';
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String company;
  Model models = Model();
  DataController dataController = new DataController();

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
                  primary: 'Register\nCompany',
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
                                'Register You Company',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Your company name should be unique and something you strongly identify with',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              ElevatedTextField.special(
                                onSaved: (companyValue) {
                                  company = companyValue;
                                },
                                icon: Icons.work,
                                label: 'Company Name',
                                obscureText: false,
                                inputFormatter: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[A-Za-z]')),
                                  LengthLimitingTextInputFormatter(10),
                                ],
                              ).getWidget(),
                              SizedBox(
                                height: 25,
                              ),
                              StadiumButton(
                                onPressed: () {
                                  _formKey.currentState.save();
                                  setState(() async {
                                    if (company != null) {
                                      await ifCompanyExists(company);
                                      if (dataController.companyExists ==
                                          false) {
                                        models.user['companyName'] =
                                            company.toUpperCase();
                                        models.user['uid'] =
                                            UserController().currentUser().uid;
                                        models.user['email'] = UserController()
                                            .currentUser()
                                            .email;
                                        models.company['companyName'] =
                                            models.user['companyName'];
                                        print(models.company['companyName']);
                                        await dataController
                                            .uploadUserData(models.user);
                                        await dataController.uploadCompanyData(
                                            models.company,
                                            models.company['companyName']);
                                        Navigator.pop(context);
                                        Navigator.pushNamed(
                                            context, HomePage.id);
                                      } else {
                                        AlertMessage(
                                                context: context,
                                                title: 'Error',
                                                message:
                                                    'The name is already taken')
                                            .getWidget();
                                      }
                                    } else {
                                      AlertMessage(
                                              context: context,
                                              title: 'Error',
                                              message:
                                                  'The field provided is empty')
                                          .getWidget();
                                    }
                                  });
                                  //UserController().signOut();
                                  //Navigator.pushNamed(context, SigninPage.id);
                                },
                                text: 'Register',
                                color: Colors.red[400],
                                width: 120,
                                height: 50,
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

  void ifCompanyExists(String company) async {
    await dataController.ifCompanyDataExists(company.toUpperCase());
  }
}
