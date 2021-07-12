import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:startupsim/Controllers/DataController.dart';
import 'package:startupsim/Controllers/UserController.dart';
import 'package:startupsim/Models/models.dart';
import 'package:startupsim/Views/Accounts.dart';
import 'package:startupsim/Views/HomePage.dart';
import 'package:startupsim/Views/MailingPage.dart';
import 'package:startupsim/Widgets/ElevatedTextField.dart';
import 'package:startupsim/Widgets/StadiumButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:startupsim/Widgets/StockCard.dart';
import 'package:startupsim/Widgets/TaskCard.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class FinancesPage extends StatefulWidget {
  static const String id = 'financesPage';
  @override
  _FinancesPageState createState() => _FinancesPageState();
}

class _FinancesPageState extends State<FinancesPage> {
  ZoomPanBehavior _zoomPanBehavior;
  TrackballBehavior _trackballBehavior;
  int _selectedIndex = 0;
  int _subContent = 0;
  Model models = Model();
  DataController dataController = DataController();
  CollectionReference users = FirebaseFirestore.instance.collection('/users');
  CollectionReference company =
      FirebaseFirestore.instance.collection('/company');
  final currentUser = UserController().currentUser();
  Map<String, dynamic> userData, companyData;
  String accountBalance = '10000';
  List<StockData> chartData;

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
  }

  Container getContent() {
    Container content;
    setState(() {
      if (_selectedIndex == 0) {
        //Stocks Container
        content = Container(
          padding: EdgeInsets.only(top: 60, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 200,
                width: 300,
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
              Text(
                companyData['companyName'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_upward,
                    color: Colors.green,
                    size: 30,
                  ),
                  Text(
                    '\$ ${companyData['stockValues'].last}',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  )
                ],
              ),
              StockCard(
                width: 310,
                height: 100,
                title: 'Available Stocks',
                icon: Icons.assessment,
                subtitle: '${companyData['availableStocks']}/20000',
              ).getWidget(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StockCard(
                    onPressed: () {},
                    width: 150,
                    height: 100,
                    title: 'Investors',
                    icon: Icons.people,
                    subtitle: '${companyData['investors'].length}',
                  ).getWidget(),
                  StockCard(
                    onPressed: () {},
                    width: 150,
                    height: 100,
                    title: 'Investments',
                    icon: Icons.request_page,
                    subtitle: '${companyData['investments'].length}',
                  ).getWidget(),
                ],
              )
            ],
          ),
        );
      } else {
        //Funding Container
        content = Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.blueGrey,
        );
      }
    });
    return content;
  }

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
    accountBalance = companyData['accountBalance'].toString();
    if (companyData != null) {
      getStocks();
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
              icon: Icon(Icons.timeline),
              label: 'Stocks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on),
              label: 'Stock Market',
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
