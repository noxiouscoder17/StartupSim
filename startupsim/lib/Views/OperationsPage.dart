import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:startupsim/Controllers/DataController.dart';
import 'package:startupsim/Controllers/UserController.dart';
import 'package:startupsim/Models/models.dart';
import 'package:startupsim/Views/Accounts.dart';
import 'package:startupsim/Views/HomePage.dart';
import 'package:startupsim/Views/MailingPage.dart';
import 'package:startupsim/Views/TaskPage.dart';
import 'package:startupsim/Widgets/Alert.dart';
import 'package:startupsim/Widgets/ElevatedTextField.dart';
import 'package:startupsim/Widgets/StadiumButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:startupsim/Widgets/StockCard.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class OperationsPage extends StatefulWidget {
  static const String id = 'operationsPage';
  @override
  _OperationsPageState createState() => _OperationsPageState();
}

class _OperationsPageState extends State<OperationsPage> {
  final _formKey = GlobalKey<FormState>();
  int _selectedIndex = 0;
  String dropdownValue = 'Add Product';
  String newProduct;
  Model models = Model();
  DataController dataController = DataController();
  CollectionReference users = FirebaseFirestore.instance.collection('/users');
  CollectionReference company =
      FirebaseFirestore.instance.collection('/company');
  final currentUser = UserController().currentUser();
  Map<String, dynamic> userData, companyData, productData;
  List<DropdownMenuItem> dropdownItems = [];
  List<PieData> pieData = [];
  DateTime now = DateTime.now();
  DateTime currentDateTime;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print(_selectedIndex);
    });
  }

  bool ifProductExist(String productName) {
    bool value = false;
    companyData['products'].forEach((element) {
      if (productName == element['productName']) {
        value = true;
      }
    });
    return value;
  }

  void getProductData() {
    companyData['products'].forEach((element) {
      if (element['productName'] == dropdownValue) {
        productData = element;
      }
    });
    if (productData != null) {
      if (productData['usability'] != null) {
        getPieData();
      }
    }
  }

  void getPieData() {
    pieData = [
      PieData(
        'Usability',
        productData['usability'] + 1,
        Colors.indigo[200],
      ),
      PieData(
        'Scalability',
        productData['scalability'] + 1,
        Colors.lightGreen[200],
      ),
      PieData(
        'Security',
        productData['security'] + 1,
        Colors.brown[200],
      ),
    ];
  }

  Container getSubContent() {
    Container content;
    if (dropdownValue == 'Add Product' || dropdownValue == null) {
      content = Container(
        child: Column(
          children: [
            SizedBox(
              height: 150,
            ),
            Text(
              'Cost to create a product is\n \$5000',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 50,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    width: 300,
                    child: ElevatedTextField.special(
                      onSaved: (productValue) {
                        if (productValue.length == 0) {
                          newProduct = null;
                        } else {
                          newProduct = productValue;
                        }
                      },
                      icon: Icons.important_devices,
                      label: 'Product Name',
                      obscureText: false,
                      inputFormatter: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ).getWidget(),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  StadiumButton(
                    text: 'Add Product',
                    color: Colors.red[400],
                    width: 100,
                    height: 50,
                    onPressed: () {
                      _formKey.currentState.save();
                      setState(() async {
                        if (companyData != null) {
                          if (newProduct != null) {
                            if (companyData['accountBalance'] >= 5000) {
                              if (ifProductExist(newProduct) == false) {
                                await addProduct();
                                await addExp(700);
                                await addTransaction(
                                    'expense', 'Operations', 5000);
                                await dataController.updateCompanyData(
                                    companyData, companyData['companyName']);
                                AlertMessage(
                                  context: context,
                                  title: 'Sucess',
                                  message: 'Product added',
                                ).getWidget();
                              } else {
                                AlertMessage(
                                        context: context,
                                        title: 'Error',
                                        message: 'The product already exists')
                                    .getWidget();
                              }
                            } else {
                              AlertMessage(
                                      context: context,
                                      title: 'Error',
                                      message: 'Account balance too low')
                                  .getWidget();
                            }
                          } else {
                            AlertMessage(
                                    context: context,
                                    title: 'Error',
                                    message: 'The field provided is empty')
                                .getWidget();
                          }
                        }
                      });
                    },
                  ).getWidget(),
                ],
              ),
            )
          ],
        ),
      );
    } else {
      if (dropdownValue != null) {
        content = Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              Card(
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                child: Container(
                  width: 310,
                  height: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        productData['productName'],
                        style: TextStyle(
                          fontSize: 35,
                        ),
                      ),
                      Text(
                        'version: ${productData['majorVersion']}.${productData['minorVersion']}.${productData['patchesVersion']}',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: Container(
                      width: 150,
                      height: 150,
                      child: SfCircularChart(series: <CircularSeries>[
                        // Render pie chart
                        PieSeries<PieData, String>(
                            dataSource: pieData,
                            pointColorMapper: (PieData data, _) => data.color,
                            xValueMapper: (PieData data, _) => data.x,
                            yValueMapper: (PieData data, _) => data.y)
                      ]),
                    ),
                  ),
                  Card(
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: Container(
                      width: 150,
                      height: 150,
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                color: Colors.indigo[200],
                                width: 20,
                                height: 20,
                              ),
                              Text('Usability')
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                color: Colors.lightGreen[200],
                                width: 20,
                                height: 20,
                              ),
                              Text('Scalability')
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                color: Colors.brown[200],
                                width: 20,
                                height: 20,
                              ),
                              Text('Security')
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: Container(
                      alignment: Alignment.center,
                      width: 150,
                      height: 50,
                      child: Text('Users : ${productData['userBase']}'),
                    ),
                  ),
                  Card(
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: Container(
                      alignment: Alignment.center,
                      width: 150,
                      height: 50,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, TaskPage.id);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 150,
                          height: 50,
                          child: Text(
                            'Updates : ${productData['finishedTasks'].length}',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Card(
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Colors.white,
                child: Container(
                  width: 310,
                  height: 200,
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 150,
                            height: 60,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.memory,
                                        size: 17,
                                      ),
                                      Text('AI :'),
                                    ],
                                  ),
                                ),
                                Text('${productData['ai'].toInt()}'),
                              ],
                            ),
                          ),
                          Container(
                            width: 150,
                            height: 60,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.phone_android,
                                        size: 15,
                                      ),
                                      Text(
                                        'UI :',
                                      ),
                                    ],
                                  ),
                                ),
                                Text('${productData['ui'].toInt()}'),
                              ],
                            ),
                          ),
                          Container(
                            width: 150,
                            height: 60,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.settings_applications,
                                        size: 17,
                                      ),
                                      Text(
                                        'Backend :',
                                      ),
                                    ],
                                  ),
                                ),
                                Text('${productData['backend'].toInt()}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 150,
                            height: 60,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.admin_panel_settings,
                                        size: 17,
                                      ),
                                      Text('Security :'),
                                    ],
                                  ),
                                ),
                                Text('${productData['cyberSecurity'].toInt()}'),
                              ],
                            ),
                          ),
                          Container(
                            width: 150,
                            height: 60,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.storage,
                                        size: 17,
                                      ),
                                      Text(
                                        'Database :',
                                      ),
                                    ],
                                  ),
                                ),
                                Text('${productData['database'].toInt()}'),
                              ],
                            ),
                          ),
                          Container(
                            width: 150,
                            height: 60,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.wifi,
                                        size: 17,
                                      ),
                                      Text(
                                        'Network :',
                                      ),
                                    ],
                                  ),
                                ),
                                Text('${productData['network'].toInt()}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
    return content;
  }

  Container getContent() {
    Container content;
    if (_selectedIndex == 0) {
      //Products Page
      content = Container(
          margin: EdgeInsets.only(top: 20),
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  height: 30,
                  child: DropdownButton(
                    isExpanded: true,
                    items: getDropdownList(),
                    onChanged: (value) {
                      setState(() {
                        dropdownValue = value;
                        getProductData();
                      });
                    },
                    value: dropdownValue,
                    elevation: 16,
                  ),
                ),
                getSubContent(),
              ],
            ),
          ));
    } else {
      //Employees Page
      content = Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: 20),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 10,
                  child: Container(
                    width: 150,
                    height: 170,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Employees :'),
                            Text('${companyData['aiEmployees']['Total']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Salary :'),
                            Text(
                                '${companyData['aiEmployees']['Total'] * companyData['aiEmployees']['salary']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Morale :'),
                            Text('${companyData['aiEmployees']['morale']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() async {
                                  await calculateCut(
                                      companyData['aiEmployees']);
                                  await dataController.updateCompanyData(
                                      companyData, companyData['companyName']);
                                });
                              },
                              child: Text('Cut'),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.red[400]),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() async {
                                  await calculateRaise(
                                      companyData['aiEmployees']);
                                  await dataController.updateCompanyData(
                                      companyData, companyData['companyName']);
                                });
                              },
                              child: Text('Raise'),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green[400]),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 10,
                  child: Container(
                    width: 150,
                    height: 170,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Employees :'),
                            Text('${companyData['uiEmployees']['Total']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Salary :'),
                            Text(
                                '${companyData['uiEmployees']['Total'] * companyData['uiEmployees']['salary']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Morale :'),
                            Text('${companyData['uiEmployees']['morale']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() async {
                                  await calculateCut(
                                      companyData['uiEmployees']);
                                  await dataController.updateCompanyData(
                                      companyData, companyData['companyName']);
                                });
                              },
                              child: Text('Cut'),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.red[400]),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() async {
                                  await calculateRaise(
                                      companyData['uiEmployees']);
                                  await dataController.updateCompanyData(
                                      companyData, companyData['companyName']);
                                });
                              },
                              child: Text('Raise'),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green[400]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 10,
                  child: Container(
                    width: 150,
                    height: 170,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Employees :'),
                            Text('${companyData['backendEmployees']['Total']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Salary :'),
                            Text(
                                '${companyData['backendEmployees']['Total'] * companyData['backendEmployees']['salary']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Morale :'),
                            Text(
                                '${companyData['backendEmployees']['morale']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() async {
                                  await calculateCut(
                                      companyData['backendEmployees']);
                                  await dataController.updateCompanyData(
                                      companyData, companyData['companyName']);
                                });
                              },
                              child: Text('Cut'),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.red[400]),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() async {
                                  await calculateRaise(
                                      companyData['backendEmployees']);
                                  await dataController.updateCompanyData(
                                      companyData, companyData['companyName']);
                                });
                              },
                              child: Text('Raise'),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green[400]),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 10,
                  child: Container(
                    width: 150,
                    height: 170,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Employees :'),
                            Text(
                                '${companyData['cyberSecurityEmployees']['Total']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Salary :'),
                            Text(
                                '${companyData['cyberSecurityEmployees']['Total'] * companyData['cyberSecurityEmployees']['salary']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Morale :'),
                            Text(
                                '${companyData['cyberSecurityEmployees']['morale']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() async {
                                  await calculateCut(
                                      companyData['cyberSecurityEmployees']);
                                  await dataController.updateCompanyData(
                                      companyData, companyData['companyName']);
                                });
                              },
                              child: Text('Cut'),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.red[400]),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() async {
                                  await calculateRaise(
                                      companyData['cyberSecurityEmployees']);
                                  await dataController.updateCompanyData(
                                      companyData, companyData['companyName']);
                                });
                              },
                              child: Text('Raise'),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green[400]),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 10,
                  child: Container(
                    width: 150,
                    height: 170,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Employees :'),
                            Text(
                                '${companyData['databaseEmployees']['Total']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Salary :'),
                            Text(
                                '${companyData['databaseEmployees']['Total'] * companyData['databaseEmployees']['salary']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Morale :'),
                            Text(
                                '${companyData['databaseEmployees']['morale']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() async {
                                  await calculateCut(
                                      companyData['databaseEmployees']);
                                  await dataController.updateCompanyData(
                                      companyData, companyData['companyName']);
                                });
                              },
                              child: Text('Cut'),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.red[400]),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() async {
                                  await calculateRaise(
                                      companyData['databaseEmployees']);
                                  await dataController.updateCompanyData(
                                      companyData, companyData['companyName']);
                                });
                              },
                              child: Text('Raise'),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green[400]),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 10,
                  child: Container(
                    width: 150,
                    height: 170,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Employees :'),
                            Text('${companyData['networkEmployees']['Total']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Salary :'),
                            Text(
                                '${companyData['networkEmployees']['Total'] * companyData['networkEmployees']['salary']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Morale :'),
                            Text(
                                '${companyData['networkEmployees']['morale']}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() async {
                                  await calculateCut(
                                      companyData['networkEmployees']);
                                  await dataController.updateCompanyData(
                                      companyData, companyData['companyName']);
                                });
                              },
                              child: Text('Cut'),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.red[400]),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() async {
                                  await calculateRaise(
                                      companyData['networkEmployees']);
                                  await dataController.updateCompanyData(
                                      companyData, companyData['companyName']);
                                });
                              },
                              child: Text('Raise'),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green[400]),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return content;
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
    if (companyData != null) {
      getProductData();
    }
    now = DateTime.now();
    currentDateTime = DateTime(
        now.year, now.month, now.day, now.hour, now.minute, now.second);
  }

  List<DropdownMenuItem> getDropdownList() {
    List<DropdownMenuItem> items = [
      DropdownMenuItem(
        child: Text('Add Product'),
        value: 'Add Product',
      ),
    ];
    if (companyData['products'].isNotEmpty)
      companyData['products'].forEach((element) {
        items.add(DropdownMenuItem(
          child: Text(element['productName']),
          value: '${element['productName']}',
        ));
      });
    return items;
  }

  void calculateRaise(Map<String, dynamic> data) {
    data['salary'] = data['salary'] + (0.2 * data['salary']).toInt();
    if (data['salary'] < 200) {
      data['salary'] = 200;
    } else {
      data['morale'] = data['morale'] + (0.2 * data['morale']).toInt();
      if (data['morale'] >= 100) {
        data['morale'] = 100;
      } else if (data['morale'] <= 0) {
        data['morale'] = 20;
      }
    }
    companyData['exp'] =
        companyData['exp'] + ((10 / (companyData['level'] * 1000)) * 100);
    if (companyData['exp'] >= 100) {
      companyData['exp'] = companyData['exp'] - 100;
      companyData['level']++;
    }
  }

  void calculateCut(Map<String, dynamic> data) {
    data['salary'] = data['salary'] - (0.2 * data['salary']).toInt();
    if (data['salary'] < 200) {
      data['salary'] = 200;
    } else {
      data['morale'] = data['morale'] - (0.2 * data['morale']).toInt();
      if (data['morale'] >= 100) {
        data['morale'] = 80;
      } else if (data['morale'] <= 0) {
        data['morale'] = 0;
      }
    }
    addExp(10);
    //companyData['exp'] =
    //    companyData['exp'] + ((10 / (companyData['level'] * 1000)) * 100);
    //if (companyData['exp'] >= 100) {
    //companyData['exp'] = companyData['exp'] - 100;
    //companyData['level']++;
    //}
  }

  void addExp(int exp) {
    companyData['exp'] =
        companyData['exp'] + ((exp / (companyData['level'] * 1000)) * 100);
    if (companyData['exp'] >= 100) {
      companyData['exp'] = companyData['exp'] - 100;
      companyData['level']++;
    }
  }

  void addProduct() {
    companyData['accountBalance'] = companyData['accountBalance'] - 5000;
    models.product['productName'] = newProduct;
    companyData['products'].add(models.product);
    companyData['totalProducts'] = companyData['products'].length;
  }

  void addTransaction(String type, String purpose, int amount) {
    models.transactions['time'] = currentDateTime;
    models.transactions['type'] = type;
    models.transactions['purpose'] = purpose;
    models.transactions['amount'] = amount;
    companyData['transactions'].add(models.transactions);
  }

  @override
  Widget build(BuildContext context) {
    if (companyData != null) {
      getDropdownList();
    }
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
              icon: Icon(Icons.email),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, MailingPage.id);
              },
            ),
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
              icon: Icon(Icons.important_devices),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Employees',
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

class PieData {
  PieData(this.x, this.y, [this.color]);
  final String x;
  final int y;
  final Color color;
}
