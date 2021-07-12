import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startupsim/Controllers/DataController.dart';
import 'package:startupsim/Controllers/UserController.dart';
import 'package:startupsim/Models/models.dart';
import 'package:startupsim/Views/Accounts.dart';
import 'package:startupsim/Views/CampaignsPage.dart';
import 'package:startupsim/Views/FinancesPage.dart';
import 'package:startupsim/Views/OperationsPage.dart';
import 'package:startupsim/Views/SigninPage.dart';
import 'package:startupsim/Widgets/CurvedContainer.dart';
import 'package:startupsim/Widgets/CircularButton.dart';
import 'package:startupsim/Widgets/TaskCard.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  static const String id = 'homePage';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation degOneTranslationAnimation,
      degTwoTranslationAnimation,
      degThreeTranslationAnimation;
  Animation rotationAnimation;
  ZoomPanBehavior _zoomPanBehavior;
  TrackballBehavior _trackballBehavior;
  Model models = Model();
  DataController dataController = DataController();
  CollectionReference users = FirebaseFirestore.instance.collection('/users');
  CollectionReference company =
      FirebaseFirestore.instance.collection('/company');
  final currentUser = UserController().currentUser();
  Map<String, dynamic> userData, companyData;
  String accountBalance = '10000';
  List<StockData> chartData;
  List<Card> ongoingTasks = [
    Card(
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      color: Colors.white,
      child: Container(
        alignment: Alignment.center,
        width: 250,
        height: 100,
        child: Text(
          'No Ongoing Tasks',
          style: TextStyle(fontSize: 17),
        ),
      ),
    )
  ];
  DateTime now = DateTime.now(), currentDateTime;

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
      // Enables the trackball
      enable: true,
      tooltipSettings: InteractiveTooltip(
        enable: true,
        color: Colors.red,
      ),
    );
    _zoomPanBehavior = ZoomPanBehavior(
        // Enables pinch zooming
        enablePinching: true);
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.2), weight: 75.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 25.0),
    ]).animate(animationController);
    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.4), weight: 55.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.4, end: 1.0), weight: 45.0),
    ]).animate(animationController);
    degThreeTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.75), weight: 35.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.75, end: 1.0), weight: 65.0),
    ]).animate(animationController);
    rotationAnimation = Tween<double>(begin: 180.0, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut));
    super.initState();
    animationController.addListener(() {
      setState(() {});
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
    accountBalance = companyData['accountBalance'].toString();
    if (companyData != null) {
      getStocks();
      updateStocks();
    }
    now = DateTime.now();
    currentDateTime = DateTime(
        now.year, now.month, now.day, now.hour, now.minute, now.second);
    if (companyData != null) {
      checkTaskFinish();
      getOngoingList();
    }
  }

  void addTransaction(String type, String purpose, int amount) {
    models.transactions['time'] = currentDateTime;
    models.transactions['type'] = type;
    models.transactions['purpose'] = purpose;
    models.transactions['amount'] = amount;
    companyData['transactions'].add(models.transactions);
  }

  void addExp(int exp) {
    companyData['exp'] =
        companyData['exp'] + ((exp / (companyData['level'] * 1000)) * 100);
    if (companyData['exp'] >= 100) {
      companyData['exp'] = companyData['exp'] - 100;
      companyData['level']++;
    }
  }

  void getStocks() {
    setState(() {
      chartData = [
        StockData(index: 1, stocks: companyData['stockValues'][0].toDouble()),
        StockData(index: 2, stocks: companyData['stockValues'][1].toDouble()),
        StockData(index: 3, stocks: companyData['stockValues'][2].toDouble()),
        StockData(index: 4, stocks: companyData['stockValues'][3].toDouble()),
        StockData(index: 5, stocks: companyData['stockValues'][4].toDouble()),
        StockData(index: 6, stocks: companyData['stockValues'][5].toDouble()),
      ];
    });
  }

  Color getStockColor() {
    if (companyData['stockValues'][4].toDouble() >
        companyData['stockValues'][5].toDouble()) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  IconData getStockIcon() {
    if (companyData['stockValues'][4].toDouble() >
        companyData['stockValues'][5].toDouble()) {
      return Icons.arrow_downward;
    } else {
      return Icons.arrow_upward;
    }
  }

  void updateStocks() {
    DateTime date = companyData['nextStock'].toDate();
    if (companyData['nextStock'] == null ||
        date.isBefore(currentDateTime) ||
        date.isAtSameMomentAs(currentDateTime)) {
      double newValue = (companyData['userBase'] * 0.001) +
          (companyData['level'] * 0.2) +
          (companyData['reputation'] * 0.07) +
          (companyData['products'].length * 0.9);
      companyData['stockValues'][0] = companyData['stockValues'][1].toDouble();
      companyData['stockValues'][1] = companyData['stockValues'][2].toDouble();
      companyData['stockValues'][2] = companyData['stockValues'][3].toDouble();
      companyData['stockValues'][3] = companyData['stockValues'][4].toDouble();
      companyData['stockValues'][4] = companyData['stockValues'][5].toDouble();
      companyData['stockValues'][5] = newValue;
      companyData['nextStock'] = currentDateTime.add(Duration(minutes: 30));
      dataController.updateCompanyData(companyData, companyData['companyName']);
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

  String format(Duration d) {
    return d.toString().split('.').first.padLeft(8, "0");
  }

  void getOngoingList() {
    List<Card> ongoing = [];
    companyData['products'].forEach((product) {
      if (product['ongoingTasks'] != null) {
        Duration eta = (product['ongoingTasks']['eta'].toDate())
            .difference(currentDateTime);
        ongoing.add(TaskCard(
          name: '${product['productName']}',
          type: '\$ ${product['ongoingTasks']['estimatedCost']}',
          color: Colors.green,
          eta: format(eta),
        ).getWidget());
      }
    });
    if (ongoing.isEmpty) {
      ongoing.add(Card(
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        color: Colors.white,
        child: Container(
          alignment: Alignment.center,
          width: 250,
          height: 100,
          child: Text(
            'No Ongoing Tasks',
            style: TextStyle(fontSize: 17),
          ),
        ),
      ));
    }
    ongoingTasks = ongoing;
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
        drawer: Drawer(
          elevation: 20,
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  height: 99,
                  padding: EdgeInsets.only(right: 30, top: 30),
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Updates',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: TopLeftCurvedContainer(
                    color: Colors.red[400],
                    child: SingleChildScrollView(
                      child: Column(
                        children: ongoingTasks,
                      ),
                    ),
                  ).getWidget(),
                ),
              ],
            ),
          ),
        ),
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
                companyData['level'].toString(),
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
              icon: Icon(Icons.logout),
              onPressed: () {
                UserController().signOut();
                Navigator.pop(context);
                Navigator.pushNamed(context, SigninPage.id);
              },
            ),
          ],
        ),
        floatingActionButton: expandableFab(),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  companyData['companyName'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      getStockIcon(),
                      color: getStockColor(),
                      size: 40,
                    ),
                    Text(
                      '\$ ${companyData['stockValues'].last.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: getStockColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    )
                  ],
                ),
                Container(
                  height: 200,
                  child: SfCartesianChart(
                    zoomPanBehavior: _zoomPanBehavior,
                    trackballBehavior: _trackballBehavior,
                    primaryXAxis: NumericAxis(),
                    series: <ChartSeries>[
                      AreaSeries<StockData, int>(
                        borderColor: Colors.green,
                        borderWidth: 3,
                        color: Colors.green[300],
                        dataSource: chartData,
                        xValueMapper: (StockData stocks, _) => stocks.index,
                        yValueMapper: (StockData stocks, _) => stocks.stocks,
                        markerSettings: MarkerSettings(
                          isVisible: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 140,
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.group),
                          Text(
                            ' Userbase',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      width: 140,
                      height: 50,
                      child: Text(
                        companyData['userBase'].toString(),
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 140,
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.auto_awesome),
                          Text(
                            ' Level',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      width: 140,
                      height: 50,
                      child: Text(
                        companyData['level'].toString(),
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 140,
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.star),
                          Text(
                            ' Reputation',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      width: 140,
                      height: 50,
                      child: Text(
                        '${companyData['reputation']}%',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 140,
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.addchart),
                          Text(
                            ' Products',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      width: 140,
                      height: 50,
                      child: Text(
                        '${companyData['totalProducts']}',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 140,
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.person),
                          Text(
                            ' Employees',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      width: 140,
                      height: 50,
                      child: Text(
                        '${companyData['aiEmployees']['Total'] + companyData['uiEmployees']['Total'] + companyData['backendEmployees']['Total'] + companyData['cyberSecurityEmployees']['Total'] + companyData['databaseEmployees']['Total'] + companyData['networkEmployees']['Total']}',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Stack expandableFab() {
    return Stack(
      children: <Widget>[
        Positioned(
            right: 0,
            bottom: 0,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: <Widget>[
                IgnorePointer(
                  child: Container(
                    color: Colors.transparent,
                    height: 150.0,
                    width: 150.0,
                  ),
                ),
                Transform.translate(
                  offset: Offset.fromDirection(getRadiansFromDegree(270),
                      degOneTranslationAnimation.value * 100),
                  child: Transform(
                    transform: Matrix4.rotationZ(
                        getRadiansFromDegree(rotationAnimation.value))
                      ..scale(degOneTranslationAnimation.value),
                    alignment: Alignment.center,
                    child: CircularButton(
                      color: Colors.green,
                      width: 50,
                      height: 50,
                      icon: Icon(
                        Icons.attach_money,
                        color: Colors.white,
                      ),
                      onClick: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, FinancesPage.id);
                        print('First Button');
                      },
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset.fromDirection(getRadiansFromDegree(225),
                      degTwoTranslationAnimation.value * 100),
                  child: Transform(
                    transform: Matrix4.rotationZ(
                        getRadiansFromDegree(rotationAnimation.value))
                      ..scale(degTwoTranslationAnimation.value),
                    alignment: Alignment.center,
                    child: CircularButton(
                      color: Colors.deepOrange,
                      width: 50,
                      height: 50,
                      icon: Icon(
                        Icons.addchart,
                        color: Colors.white,
                      ),
                      onClick: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, OperationsPage.id);
                        print('Second button');
                      },
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset.fromDirection(getRadiansFromDegree(180),
                      degThreeTranslationAnimation.value * 100),
                  child: Transform(
                    transform: Matrix4.rotationZ(
                        getRadiansFromDegree(rotationAnimation.value))
                      ..scale(degThreeTranslationAnimation.value),
                    alignment: Alignment.center,
                    child: CircularButton(
                      color: Colors.orangeAccent,
                      width: 50,
                      height: 50,
                      icon: Icon(
                        Icons.campaign,
                        color: Colors.white,
                      ),
                      onClick: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, CampaignsPage.id);
                        print('Third Button');
                      },
                    ),
                  ),
                ),
                Transform(
                  transform: Matrix4.rotationZ(
                      getRadiansFromDegree(rotationAnimation.value)),
                  alignment: Alignment.center,
                  child: CircularButton(
                    color: Colors.red[400],
                    width: 60,
                    height: 60,
                    icon: Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                    ),
                    onClick: () {
                      if (animationController.isCompleted) {
                        animationController.reverse();
                      } else {
                        animationController.forward();
                      }
                    },
                  ),
                )
              ],
            ))
      ],
    );
  }
}

class StockData {
  int index;
  double stocks;
  StockData({this.index, this.stocks});
}
