import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:startupsim/Controllers/DataController.dart';
import 'package:startupsim/Controllers/UserController.dart';
import 'package:startupsim/Models/models.dart';
import 'package:startupsim/Views/Accounts.dart';
import 'package:startupsim/Views/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:startupsim/Widgets/Alert.dart';
import 'package:startupsim/Widgets/StadiumButton.dart';

class TaskPage extends StatefulWidget {
  static const String id = 'taskPage';
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  Model models = Model();
  DataController dataController = DataController();
  CollectionReference users = FirebaseFirestore.instance.collection('/users');
  CollectionReference company =
      FirebaseFirestore.instance.collection('/company');
  final currentUser = UserController().currentUser();
  Map<String, dynamic> userData, companyData, productData;
  List<DropdownMenuItem> dropdownItems = [];
  List<Card> updateList = [];
  String dropdownValue;
  int _selectedIndex = 0,
      estimatedCost = 0,
      remainingComponents = 0,
      totalComponents = 0,
      aiCount = 0,
      uiCount = 0,
      backendCount = 0,
      cyberSecurityCount = 0,
      databaseCount = 0,
      networkCount = 0,
      userIncrease = 0,
      usabilityIncrease = 0,
      scalabilityIncrease = 0,
      securityIncrease = 0;
  double aiEmployees = 0,
      totalEmployees = 0,
      uiEmployees = 0,
      backendEmployees = 0,
      cyberSecurityEmployees = 0,
      databaseEmployees = 0,
      networkEmployees = 0,
      aiComponents = 0,
      uiComponents = 0,
      backendComponents = 0,
      cyberSecurityComponents = 0,
      databaseComponents = 0,
      networkComponents = 0;
  DateTime now = DateTime.now();
  DateTime currentDateTime, estimatedTime;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print(_selectedIndex);
    });
  }

  void fetchUserData() async {
    await users.doc(currentUser.uid).get().then((querySnapshots) {
      setState(() {
        userData = querySnapshots.data() as Map<String, dynamic>;
      });
    });
  }

  void fetchCompanyData() async {
    await company.doc(userData['companyName']).get().then((querySnapshots) {
      setState(() {
        companyData = querySnapshots.data() as Map<String, dynamic>;
      });
    });
    now = DateTime.now();
    currentDateTime = DateTime(
        now.year, now.month, now.day, now.hour, now.minute, now.second);
    if (companyData != null) {
      getProductData();
      getCost();
      checkTaskFinish();
      getTransactionList();
    }
  }

  void getProductData() {
    companyData['products'].forEach((element) {
      if (element['productName'] == dropdownValue) {
        productData = element;
      }
    });
  }

  void addExp(int exp) {
    companyData['exp'] =
        companyData['exp'] + ((exp / (companyData['level'] * 1000)) * 100);
    if (companyData['exp'] >= 100) {
      companyData['exp'] = companyData['exp'] - 100;
      companyData['level']++;
    }
  }

  void addTransaction(String type, String purpose, int amount) {
    models.transactions['time'] = currentDateTime;
    models.transactions['type'] = type;
    models.transactions['purpose'] = purpose;
    models.transactions['amount'] = amount;
    companyData['transactions'].add(models.transactions);
  }

  List<DropdownMenuItem> getDropdownList() {
    List<DropdownMenuItem> items = [];
    if (companyData['products'].isNotEmpty)
      companyData['products'].forEach((element) {
        if (element['ongoingTasks'] == null) {
          items.add(DropdownMenuItem(
            child: Text(element['productName']),
            value: '${element['productName']}',
          ));
        }
      });
    return items;
  }

  void getTransactionList() {
    List<Card> updates = [];
    companyData['products'].forEach((product) {
      product['finishedTasks'].forEach((task) {
        DateTime date = task['time'].toDate();
        updates.add(Card(
          elevation: 16,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          color: Colors.white,
          child: Container(
            width: 300,
            height: 150,
            padding: EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${product['productName']}',
                  style: TextStyle(fontSize: 21),
                ),
                Text(
                  '${task['majorVersion']}.${task['minorVersion']}.${task['patchesVersion']}',
                  style: TextStyle(fontSize: 17),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Released on : '),
                      Text('${date.day}-${date.month}-${date.year}'),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cost : '),
                      Text('\$ ${task['cost']}'),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('User Increased : '),
                      Text('${task['userIncrease']}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
      });
    });
    if (updates.isEmpty) {
      updates.add(Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
            alignment: Alignment.center,
            width: 350,
            height: 70,
            padding: EdgeInsets.all(8),
            child: Text('No Records')),
      ));
    }
    updateList = updates;
  }

  void getCost() {
    setState(() {
      aiCount = (companyData['aiEmployees']['Total'] -
              companyData['aiEmployees']['working'])
          .toInt();
      uiCount = (companyData['uiEmployees']['Total'] -
              companyData['uiEmployees']['working'])
          .toInt();
      backendCount = (companyData['backendEmployees']['Total'] -
              companyData['backendEmployees']['working'])
          .toInt();
      cyberSecurityCount = (companyData['cyberSecurityEmployees']['Total'] -
              companyData['cyberSecurityEmployees']['working'])
          .toInt();
      databaseCount = (companyData['databaseEmployees']['Total'] -
              companyData['databaseEmployees']['working'])
          .toInt();
      networkCount = (companyData['networkEmployees']['Total'] -
              companyData['networkEmployees']['working'])
          .toInt();

      remainingComponents = (companyData['level'] * 5) -
          aiComponents.toInt() -
          uiComponents.toInt() -
          backendComponents.toInt() -
          cyberSecurityComponents.toInt() -
          databaseComponents.toInt() -
          networkComponents.toInt();

      estimatedCost = (aiComponents.toInt() * 4) +
          (uiComponents.toInt() * 3) +
          (backendComponents.toInt() * 3) +
          (cyberSecurityComponents.toInt() * 5) +
          (databaseComponents.toInt() * 2) +
          (networkComponents.toInt() * 4);

      totalComponents = companyData['level'] * 5;
      totalEmployees = aiEmployees +
          uiEmployees +
          backendEmployees +
          cyberSecurityEmployees +
          databaseEmployees +
          networkEmployees;
      int selectedComponents = (totalComponents - remainingComponents) * 15;
      int selectedEmployees =
          (totalEmployees.toInt() == 0) ? 1 : totalEmployees.toInt();
      estimatedTime = currentDateTime.add(
          Duration(minutes: (selectedComponents / selectedEmployees).toInt()));

      userIncrease = (aiComponents.toInt() * 2) +
          (uiComponents.toInt() * 3) +
          (backendComponents.toInt() * 1) +
          (cyberSecurityComponents.toInt() * 0) +
          (databaseComponents.toInt() * 2) +
          (networkComponents.toInt() * 2);

      usabilityIncrease = (aiComponents.toInt() * 1) +
          (uiComponents.toInt() * 2) +
          (backendComponents.toInt() * 0) +
          (cyberSecurityComponents.toInt() * -2) +
          (databaseComponents.toInt() * 1) +
          (networkComponents.toInt() * 1);

      scalabilityIncrease = (aiComponents.toInt() * 0) +
          (uiComponents.toInt() * -1) +
          (backendComponents.toInt() * 2) +
          (cyberSecurityComponents.toInt() * -1) +
          (databaseComponents.toInt() * 1) +
          (networkComponents.toInt() * 2);

      securityIncrease = (aiComponents.toInt() * -1) +
          (uiComponents.toInt() * 0) +
          (backendComponents.toInt() * 1) +
          (cyberSecurityComponents.toInt() * 5) +
          (databaseComponents.toInt() * 0) +
          (networkComponents.toInt() * 1);
    });
  }

  void addTask() {
    getProductData();
    if (productData == null) {
      AlertMessage(
        message: 'Select a Product',
        title: 'Error',
        context: context,
      ).getWidget();
    } else {
      if (companyData['accountBalance'] < estimatedCost) {
        AlertMessage(
          title: 'Error',
          message: 'Account Balance low',
          context: context,
        ).getWidget();
      } else {
        models.ongoingTasks['eta'] = estimatedTime;
        models.ongoingTasks['uiComponents'] = uiComponents;
        models.ongoingTasks['aiComponents'] = aiComponents;
        models.ongoingTasks['backendComponents'] = backendComponents;
        models.ongoingTasks['cyberSecurityComponents'] =
            cyberSecurityComponents;
        models.ongoingTasks['databaseComponents'] = databaseComponents;
        models.ongoingTasks['networkComponents'] = networkComponents;
        models.ongoingTasks['aiEmployees'] = aiEmployees;
        models.ongoingTasks['uiEmployees'] = uiEmployees;
        models.ongoingTasks['backendEmployees'] = backendEmployees;
        models.ongoingTasks['cyberSecurityEmployees'] = cyberSecurityEmployees;
        models.ongoingTasks['databaseEmployees'] = databaseEmployees;
        models.ongoingTasks['networkEmployees'] = networkEmployees;
        models.ongoingTasks['estimatedCost'] = estimatedCost;
        models.ongoingTasks['userIncrease'] = userIncrease;
        models.ongoingTasks['usabilityIncrease'] = usabilityIncrease;
        models.ongoingTasks['scalabilityIncrease'] = scalabilityIncrease;
        models.ongoingTasks['securityIncrease'] = securityIncrease;
        productData['ongoingTasks'] = models.ongoingTasks;
        companyData['aiEmployees']['working'] =
            companyData['aiEmployees']['working'] + aiEmployees;
        companyData['uiEmployees']['working'] =
            companyData['uiEmployees']['working'] + uiEmployees;
        companyData['backendEmployees']['working'] =
            companyData['backendEmployees']['working'] + backendEmployees;
        companyData['cyberSecurityEmployees']['working'] =
            companyData['cyberSecurityEmployees']['working'] +
                cyberSecurityEmployees;
        companyData['databaseEmployees']['working'] =
            companyData['databaseEmployees']['working'] + databaseEmployees;
        companyData['networkEmployees']['working'] =
            companyData['networkEmployees']['working'] + networkEmployees;
        companyData['accountBalance'] =
            companyData['accountBalance'] - estimatedCost;
        aiComponents = 0;
        backendComponents = 0;
        cyberSecurityComponents = 0;
        uiComponents = 0;
        databaseComponents = 0;
        networkComponents = 0;
        aiEmployees = 0;
        backendEmployees = 0;
        uiEmployees = 0;
        cyberSecurityEmployees = 0;
        databaseEmployees = 0;
        networkEmployees = 0;
        addTransaction('expense', 'Operations', estimatedCost);
        addExp(200);
      }
    }
  }

  void checkTaskFinish() {
    companyData['products'].forEach((element) {
      if (element['ongoingTasks'] != null) {
        DateTime date = element['ongoingTasks']['eta'].toDate();
        if (date != null) {
          if (date.isBefore(currentDateTime) ||
              date.isAtSameMomentAs(currentDateTime)) {
            companyData['aiEmployees']['working'] = companyData['aiEmployees']
                    ['working'] -
                element['ongoingTasks']['aiEmployees'];
            companyData['uiEmployees']['working'] = companyData['uiEmployees']
                    ['working'] -
                element['ongoingTasks']['uiEmployees'];
            companyData['backendEmployees']['working'] =
                companyData['backendEmployees']['working'] -
                    element['ongoingTasks']['backendEmployees'];
            companyData['cyberSecurityEmployees']['working'] =
                companyData['cyberSecurityEmployees']['working'] -
                    element['ongoingTasks']['cyberSecurityEmployees'];
            companyData['databaseEmployees']['working'] =
                companyData['databaseEmployees']['working'] -
                    element['ongoingTasks']['databaseEmployees'];
            companyData['networkEmployees']['working'] =
                companyData['networkEmployees']['working'] -
                    element['ongoingTasks']['networkEmployees'];
            companyData['userBase'] = ((companyData['userBase'] +
                        element['ongoingTasks']['userIncrease']) *
                    companyData['userBaseMultiplier'])
                .toInt();
            int earnedMoney = element['ongoingTasks']['userIncrease'] * 10;
            companyData['accountBalance'] =
                companyData['accountBalance'] + earnedMoney;
            element['userBase'] = ((element['userBase'] +
                        element['ongoingTasks']['userIncrease']) *
                    companyData['userBaseMultiplier'])
                .toInt();
            element['usability'] = element['usability'] +
                element['ongoingTasks']['usabilityIncrease'];
            element['scalability'] = element['scalability'] +
                element['ongoingTasks']['scalabilityIncrease'];
            element['security'] = element['security'] +
                element['ongoingTasks']['securityIncrease'];
            element['ai'] =
                element['ai'] + element['ongoingTasks']['aiComponents'];
            element['ui'] =
                element['ui'] + element['ongoingTasks']['uiComponents'];
            element['backend'] = element['backend'] +
                element['ongoingTasks']['backendComponents'];
            element['cyberSecurity'] = element['cyberSecurity'] +
                element['ongoingTasks']['cyberSecurityComponents'];
            element['database'] = element['database'] +
                element['ongoingTasks']['databaseComponents'];
            element['network'] = element['network'] +
                element['ongoingTasks']['networkComponents'];
            if (element['ongoingTasks']['userIncrease'] < 50) {
              element['patchesVersion']++;
            } else if (50 < element['ongoingTasks']['userIncrease'] &&
                element['ongoingTasks']['userIncrease'] > 100) {
              element['minorVersion']++;
            } else {
              element['majorVersion']++;
            }
            models.finishedTasks['time'] = element['ongoingTasks']['eta'];
            models.finishedTasks['cost'] =
                element['ongoingTasks']['estimatedCost'];
            models.finishedTasks['userIncrease'] =
                element['ongoingTasks']['userIncrease'];
            models.finishedTasks['majorVersion'] = element['majorVersion'];
            models.finishedTasks['minorVersion'] = element['minorVersion'];
            models.finishedTasks['patchesVersion'] = element['patchesVersion'];
            element['finishedTasks'].add(models.finishedTasks);
            element['ongoingTasks'] = null;
            addExp(200);
            addTransaction('income', 'Operations', earnedMoney);
            dataController.updateCompanyData(
                companyData, companyData['companyName']);
          }
        }
      }
    });
  }

  Container getContent() {
    Container content = Container(
      width: double.infinity,
      height: double.infinity,
    );
    setState(() {
      if (_selectedIndex == 0) {
        //Add Task Page

        content = Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.only(
            top: 30,
            left: 10,
            right: 10,
            bottom: 25,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 270,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Product : ',
                      style: TextStyle(fontSize: 17),
                    ),
                    DropdownButton(
                      items: getDropdownList(),
                      onChanged: (value) {
                        setState(() {
                          dropdownValue = value;
                          getProductData();
                        });
                      },
                      value: dropdownValue,
                      elevation: 16,
                    )
                  ],
                ),
              ),
              Container(
                width: 270,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cost : ',
                      style: TextStyle(fontSize: 17),
                    ),
                    Text(
                      '\$ ${estimatedCost}',
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              ),
              Container(
                width: 270,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Remaining Components : ',
                      style: TextStyle(fontSize: 17),
                    ),
                    Text(
                      '${remainingComponents}',
                      style: TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              ),
              Container(
                width: 400,
                height: 350,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      //AI
                      Card(
                        elevation: 10,
                        child: Container(
                          width: 300,
                          height: 150,
                          padding: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.memory,
                                    size: 30,
                                  ),
                                  Text(
                                    'AI',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Employees :'),
                                  Slider(
                                    onChanged: (value) {
                                      setState(() {
                                        aiEmployees = value;
                                        if (aiEmployees != 0) {
                                          if (aiComponents == 0) {
                                            if (remainingComponents != 0) {
                                              aiComponents = aiComponents + 1;
                                            } else {
                                              aiEmployees = 0;
                                            }
                                          }
                                        } else {
                                          aiComponents = 0;
                                        }
                                      });
                                    },
                                    max: aiCount.toDouble(),
                                    divisions: (aiCount == 0) ? 1 : aiCount,
                                    value: aiEmployees,
                                    label: aiEmployees.toInt().toString(),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Components :'),
                                  Slider(
                                    onChanged: (value) {
                                      if ((value +
                                              uiComponents +
                                              backendComponents +
                                              cyberSecurityComponents +
                                              databaseComponents +
                                              networkComponents) <=
                                          totalComponents) {
                                        setState(() {
                                          aiComponents = value;
                                          if (aiComponents != 0) {
                                            if (aiEmployees == 0) {
                                              if (remainingComponents != 0) {
                                                aiEmployees = aiEmployees + 1;
                                              } else {
                                                aiComponents = 0;
                                              }
                                            }
                                          } else {
                                            aiEmployees = 0;
                                          }
                                        });
                                      }
                                    },
                                    max: (aiCount == 0)
                                        ? 0
                                        : totalComponents.toDouble(),
                                    divisions: (totalComponents == 0)
                                        ? 1
                                        : totalComponents,
                                    value: aiComponents,
                                    label: aiComponents.toInt().toString(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      //UI
                      Card(
                        elevation: 10,
                        child: Container(
                          width: 300,
                          height: 150,
                          padding: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone_android,
                                    size: 30,
                                  ),
                                  Text(
                                    'UI',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Employees :'),
                                  Slider(
                                    onChanged: (value) {
                                      setState(() {
                                        uiEmployees = value;
                                        if (uiEmployees != 0) {
                                          if (uiComponents == 0) {
                                            if (remainingComponents != 0) {
                                              uiComponents = uiComponents + 1;
                                            } else {
                                              uiEmployees = 0;
                                            }
                                          }
                                        } else {
                                          uiComponents = 0;
                                        }
                                      });
                                    },
                                    max: uiCount.toDouble(),
                                    divisions: (uiCount == 0) ? 1 : uiCount,
                                    value: uiEmployees,
                                    label: uiEmployees.toInt().toString(),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Components :'),
                                  Slider(
                                    onChanged: (value) {
                                      if ((value +
                                              aiComponents +
                                              backendComponents +
                                              cyberSecurityComponents +
                                              databaseComponents +
                                              networkComponents) <=
                                          totalComponents) {
                                        setState(() {
                                          uiComponents = value;
                                          if (uiComponents != 0) {
                                            if (uiEmployees == 0) {
                                              if (remainingComponents != 0) {
                                                uiEmployees = uiEmployees + 1;
                                              } else {
                                                uiComponents = 0;
                                              }
                                            }
                                          } else {
                                            uiEmployees = 0;
                                          }
                                        });
                                      }
                                    },
                                    max: (uiCount == 0)
                                        ? 0
                                        : totalComponents.toDouble(),
                                    divisions: (totalComponents == 0)
                                        ? 1
                                        : totalComponents,
                                    value: uiComponents,
                                    label: uiComponents.toInt().toString(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      //Backend
                      Card(
                        elevation: 10,
                        child: Container(
                          width: 300,
                          height: 150,
                          padding: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.settings_applications,
                                    size: 30,
                                  ),
                                  Text(
                                    'Backend',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Employees :'),
                                  Slider(
                                    onChanged: (value) {
                                      setState(() {
                                        backendEmployees = value;
                                        if (backendEmployees != 0) {
                                          if (backendComponents == 0) {
                                            if (remainingComponents != 0) {
                                              backendComponents =
                                                  backendComponents + 1;
                                            } else {
                                              backendEmployees = 0;
                                            }
                                          }
                                        } else {
                                          backendComponents = 0;
                                        }
                                      });
                                    },
                                    max: backendCount.toDouble(),
                                    divisions:
                                        (backendCount == 0) ? 1 : backendCount,
                                    value: backendEmployees,
                                    label: backendEmployees.toInt().toString(),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Components :'),
                                  Slider(
                                    onChanged: (value) {
                                      if ((value +
                                              uiComponents +
                                              aiComponents +
                                              cyberSecurityComponents +
                                              databaseComponents +
                                              networkComponents) <=
                                          totalComponents) {
                                        setState(() {
                                          backendComponents = value;
                                          if (backendComponents != 0) {
                                            if (backendEmployees == 0) {
                                              if (remainingComponents != 0) {
                                                backendEmployees =
                                                    backendEmployees + 1;
                                              } else {
                                                backendComponents = 0;
                                              }
                                            }
                                          } else {
                                            backendEmployees = 0;
                                          }
                                        });
                                      }
                                    },
                                    max: (backendCount == 0)
                                        ? 0
                                        : totalComponents.toDouble(),
                                    divisions: (totalComponents == 0)
                                        ? 1
                                        : totalComponents,
                                    value: backendComponents,
                                    label: backendComponents.toInt().toString(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      //CyberSecurity
                      Card(
                        elevation: 10,
                        child: Container(
                          width: 300,
                          height: 150,
                          padding: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings,
                                    size: 30,
                                  ),
                                  Text(
                                    'Security',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Employees :'),
                                  Slider(
                                    onChanged: (value) {
                                      setState(() {
                                        cyberSecurityEmployees = value;
                                        if (cyberSecurityEmployees != 0) {
                                          if (cyberSecurityComponents == 0) {
                                            if (remainingComponents != 0) {
                                              cyberSecurityComponents =
                                                  cyberSecurityComponents + 1;
                                            } else {
                                              cyberSecurityEmployees = 0;
                                            }
                                          }
                                        } else {
                                          cyberSecurityComponents = 0;
                                        }
                                      });
                                    },
                                    max: cyberSecurityCount.toDouble(),
                                    divisions: (cyberSecurityCount == 0)
                                        ? 1
                                        : cyberSecurityCount,
                                    value: cyberSecurityEmployees,
                                    label: cyberSecurityEmployees
                                        .toInt()
                                        .toString(),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Components :'),
                                  Slider(
                                    onChanged: (value) {
                                      if ((value +
                                              uiComponents +
                                              backendComponents +
                                              aiComponents +
                                              databaseComponents +
                                              networkComponents) <=
                                          totalComponents) {
                                        setState(() {
                                          cyberSecurityComponents = value;
                                          if (cyberSecurityComponents != 0) {
                                            if (cyberSecurityEmployees == 0) {
                                              if (remainingComponents != 0) {
                                                cyberSecurityEmployees =
                                                    cyberSecurityEmployees + 1;
                                              } else {
                                                cyberSecurityComponents = 0;
                                              }
                                            }
                                          } else {
                                            cyberSecurityEmployees = 0;
                                          }
                                        });
                                      }
                                    },
                                    max: (cyberSecurityCount == 0)
                                        ? 0
                                        : totalComponents.toDouble(),
                                    divisions: (totalComponents == 0)
                                        ? 1
                                        : totalComponents,
                                    value: cyberSecurityComponents,
                                    label: cyberSecurityComponents
                                        .toInt()
                                        .toString(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      //Database
                      Card(
                        elevation: 10,
                        child: Container(
                          width: 300,
                          height: 150,
                          padding: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.storage,
                                    size: 30,
                                  ),
                                  Text(
                                    'Database',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Employees :'),
                                  Slider(
                                    onChanged: (value) {
                                      setState(() {
                                        databaseEmployees = value;
                                        if (databaseEmployees != 0) {
                                          if (databaseComponents == 0) {
                                            if (remainingComponents != 0) {
                                              databaseComponents =
                                                  databaseComponents + 1;
                                            } else {
                                              databaseEmployees = 0;
                                            }
                                          }
                                        } else {
                                          databaseComponents = 0;
                                        }
                                      });
                                    },
                                    max: databaseCount.toDouble(),
                                    divisions: (databaseCount == 0)
                                        ? 1
                                        : databaseCount,
                                    value: databaseEmployees,
                                    label: databaseEmployees.toInt().toString(),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Components :'),
                                  Slider(
                                    onChanged: (value) {
                                      if ((value +
                                              uiComponents +
                                              backendComponents +
                                              cyberSecurityComponents +
                                              aiComponents +
                                              networkComponents) <=
                                          totalComponents) {
                                        setState(() {
                                          databaseComponents = value;
                                          if (databaseComponents != 0) {
                                            if (databaseEmployees == 0) {
                                              if (remainingComponents != 0) {
                                                databaseEmployees =
                                                    databaseEmployees + 1;
                                              } else {
                                                databaseComponents = 0;
                                              }
                                            }
                                          } else {
                                            databaseEmployees = 0;
                                          }
                                        });
                                      }
                                    },
                                    max: (databaseCount == 0)
                                        ? 0
                                        : totalComponents.toDouble(),
                                    divisions: (totalComponents == 0)
                                        ? 1
                                        : totalComponents,
                                    value: databaseComponents,
                                    label:
                                        databaseComponents.toInt().toString(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      //Network
                      Card(
                        elevation: 10,
                        child: Container(
                          width: 300,
                          height: 150,
                          padding: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.wifi,
                                    size: 30,
                                  ),
                                  Text(
                                    'Network',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Employees :'),
                                  Slider(
                                    onChanged: (value) {
                                      setState(() {
                                        networkEmployees = value;
                                        if (networkEmployees != 0) {
                                          if (networkComponents == 0) {
                                            if (remainingComponents != 0) {
                                              networkComponents =
                                                  networkComponents + 1;
                                            } else {
                                              networkEmployees = 0;
                                            }
                                          }
                                        } else {
                                          networkComponents = 0;
                                        }
                                      });
                                    },
                                    max: networkCount.toDouble(),
                                    divisions:
                                        (networkCount == 0) ? 1 : networkCount,
                                    value: networkEmployees,
                                    label: networkEmployees.toInt().toString(),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Components :'),
                                  Slider(
                                    onChanged: (value) {
                                      if ((value +
                                              uiComponents +
                                              backendComponents +
                                              cyberSecurityComponents +
                                              databaseComponents +
                                              aiComponents) <=
                                          totalComponents) {
                                        setState(() {
                                          networkComponents = value;
                                          if (networkComponents != 0) {
                                            if (networkEmployees == 0) {
                                              if (remainingComponents != 0) {
                                                networkEmployees =
                                                    networkEmployees + 1;
                                              } else {
                                                networkComponents = 0;
                                              }
                                            }
                                          } else {
                                            networkEmployees = 0;
                                          }
                                        });
                                      }
                                    },
                                    max: (networkCount == 0)
                                        ? 0
                                        : totalComponents.toDouble(),
                                    divisions: (totalComponents == 0)
                                        ? 1
                                        : totalComponents,
                                    value: networkComponents,
                                    label: networkComponents.toInt().toString(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              StadiumButton(
                width: 200,
                height: 50,
                text: 'Add Update',
                color: Colors.red[400],
                onPressed: () {
                  setState(() {
                    if (remainingComponents == totalComponents) {
                      AlertMessage(
                        title: 'Error',
                        message: 'Select atleast one component',
                        context: context,
                      ).getWidget();
                    } else {
                      addTask();
                      dataController.updateCompanyData(
                          companyData, companyData['companyName']);
                    }
                  });
                },
              ).getWidget(),
            ],
          ),
        );
      } else {
        //List Task Page
        content = Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.only(
            top: 30,
            left: 10,
            right: 10,
            bottom: 10,
          ),
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              children: updateList,
            ),
          ),
        );
      }
    });
    return content;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      fetchUserData();
      fetchCompanyData();
    });
    if (companyData == null) {
      setState(() {
        fetchUserData();
        fetchCompanyData();
      });
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.red[400],
          body: Center(
            child: Container(
              width: 100,
              height: 100,
              child: Image(
                image: AssetImage('images/startupsim.png'),
              ),
            ),
          ),
        ),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          bottom: AppBar(
            leadingWidth: 60,
            titleSpacing: 0,
            toolbarHeight: 15,
            backgroundColor: Colors.red[900],
            leading: Container(
              width: 35,
              height: 15,
              color: Colors.red[800],
              alignment: Alignment.center,
              child: Text(
                '${companyData['level']}',
                style: TextStyle(fontSize: 10),
              ),
            ),
            title: Container(
              height: 15,
              width: (companyData['exp'] / 100) * 300,
              color: Colors.green,
            ),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.red[400],
          title: TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AccountPage.id);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.yellow,
                  ),
                ),
                Text(
                  '\$ ${companyData['accountBalance']}',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () async {
                await Navigator.pop(context);
                await Navigator.pushNamed(context, HomePage.id);
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          onTap: _onItemTapped,
          unselectedItemColor: Colors.white54,
          backgroundColor: Colors.red[400],
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle),
              label: 'Add Update',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books_sharp),
              label: 'All Updates',
            ),
          ],
        ),
        body: SafeArea(
          child: getContent(),
        ),
      ),
    );
  }
}
