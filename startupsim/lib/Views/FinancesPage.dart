import 'package:flutter/material.dart';
import 'package:startupsim/Controllers/DataController.dart';
import 'package:startupsim/Controllers/UserController.dart';
import 'package:startupsim/Models/models.dart';
import 'package:startupsim/Views/Accounts.dart';
import 'package:startupsim/Views/HomePage.dart';
import 'package:startupsim/Widgets/Alert.dart';
import 'package:startupsim/Widgets/StadiumButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:startupsim/Widgets/StockCard.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

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
  Map<String, dynamic> userData, companyData, otherData;
  String accountBalance = '10000', dropDownValue;
  List<StockData> chartData;
  List<StockData> otherChartData;
  List<DropdownMenuItem> companyList;
  double buyCount = 0, sellCount = 0, sell = 0;
  DateTime now = DateTime.now();
  DateTime currentDateTime;

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
                    '\$ ${companyData['stockValues'].last.toStringAsFixed(2)}',
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
                    width: 150,
                    height: 100,
                    title: 'Investors',
                    icon: Icons.people,
                    subtitle: '${companyData['investors'].length}',
                  ).getWidget(),
                  StockCard(
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
          padding: EdgeInsets.only(
            top: 20,
            bottom: 10,
          ),
          child: Column(
            children: [
              Container(
                width: 300,
                height: 70,
                child: SearchableDropdown.single(
                  isExpanded: true,
                  hint: 'Search',
                  items: companyList,
                  onChanged: (value) {
                    dropDownValue = value;
                  },
                ),
              ),
              Column(
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
                          dataSource: otherChartData,
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
                    otherData['companyName'],
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
                        '\$ ${otherData['stockValues'].last.toStringAsFixed(2)}',
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
                    height: 70,
                    title: 'Available Stocks',
                    icon: Icons.assessment,
                    subtitle: '${otherData['availableStocks'].toInt()}/20000',
                  ).getWidget(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 16,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.white,
                        child: Container(
                          alignment: Alignment.center,
                          width: 150,
                          height: 130,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  '\$ ${(otherData['stockValues'].last * buyCount).toInt()}'),
                              Slider(
                                inactiveColor: Colors.green[100],
                                activeColor: Colors.green[400],
                                onChanged: (value) {
                                  setState(() {
                                    buyCount = value;
                                  });
                                },
                                max: otherData['availableStocks'].toDouble(),
                                divisions: (otherData['availableStocks'] == 0)
                                    ? 1
                                    : otherData['availableStocks'].toInt(),
                                value: buyCount,
                                label: buyCount.toInt().toString(),
                              ),
                              StadiumButton(
                                onPressed: () {
                                  setState(() {
                                    buyStocks();
                                  });
                                },
                                color: Colors.green[400],
                                text: 'Buy',
                                height: 30,
                                width: 70,
                              ).getWidget(),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        elevation: 16,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.white,
                        child: Container(
                          alignment: Alignment.center,
                          width: 150,
                          height: 130,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  '\$ ${(otherData['stockValues'].last * sell).toInt()}'),
                              Slider(
                                inactiveColor: Colors.red[100],
                                activeColor: Colors.red[400],
                                onChanged: (value) {
                                  setState(() {
                                    sell = value;
                                  });
                                },
                                max: sellCount.toDouble(),
                                divisions:
                                    (sellCount == 0) ? 1 : sellCount.toInt(),
                                value: sell,
                                label: sell.toInt().toString(),
                              ),
                              StadiumButton(
                                onPressed: () {
                                  setState(() {
                                    sellStocks();
                                  });
                                },
                                color: Colors.red[400],
                                text: 'Sell',
                                height: 30,
                                width: 70,
                              ).getWidget(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
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
    List<DropdownMenuItem> item = [];
    await company.doc(userData['companyName']).get().then((querySnapshots) {
      setState(() {
        companyData = querySnapshots.data() as Map<String, dynamic>;
      });
    });
    await company.get().then((data) {
      data.docs.forEach((company) {
        item.add(DropdownMenuItem(
          child: Text('${company['companyName']}'),
          value: company['companyName'],
        ));
      });
    });
    companyList = item;
    accountBalance = companyData['accountBalance'].toString();
    if (companyData != null) {
      getStocks();
      getOtherStocks();
    }
    fetchOtherCompanyData();
    now = DateTime.now();
    currentDateTime = DateTime(
        now.year, now.month, now.day, now.hour, now.minute, now.second);
  }

  void fetchOtherCompanyData() async {
    if (dropDownValue != null) {
      await company.doc(dropDownValue).get().then((querySnapshots) {
        setState(() {
          otherData = querySnapshots.data() as Map<String, dynamic>;
        });
      });
    } else {
      otherData = companyData;
    }
    companyData['investments'].forEach((element) {
      if (element['companyName'] == otherData['companyName']) {
        sellCount = element['stocksBought'];
      } else {
        sellCount = 0;
      }
    });
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

  void getOtherStocks() {
    if (otherData != null) {
      setState(() {
        otherChartData = [
          StockData(index: 1, stocks: otherData['stockValues'][0].toDouble()),
          StockData(index: 2, stocks: otherData['stockValues'][1].toDouble()),
          StockData(index: 3, stocks: otherData['stockValues'][2].toDouble()),
          StockData(index: 4, stocks: otherData['stockValues'][3].toDouble()),
          StockData(index: 5, stocks: otherData['stockValues'][4].toDouble()),
          StockData(index: 6, stocks: otherData['stockValues'][5].toDouble()),
        ];
      });
    }
  }

  void buyStocks() {
    int check = 0;
    companyData['investments'].forEach((element) {
      if (element['companyName'] == otherData['companyName']) {
        element['stocksBought'] = element['stocksBought'] + buyCount.toInt();
        element['boughtAt'] = (buyCount * otherData['stockValues'].last);
        check = 1;
      }
    });
    if (check == 0) {
      if (companyData['accountBalance'] >
          (buyCount * otherData['stockValues'].last).toInt()) {
        models.investors['companyName'] = otherData['companyName'];
        models.investors['stocksBought'] = buyCount.toInt();
        models.investors['boughtAt'] =
            (buyCount * otherData['stockValues'].last);
        companyData['investments'].add(models.investors);
        otherData['investors'].add(models.investors);
        companyData['accountBalance'] = companyData['accountBalance'] -
            (buyCount * otherData['stockValues'].last).toInt();
        otherData['availableStocks'] =
            otherData['availableStocks'] - buyCount.toInt();
        addExp(300);
        addTransaction('expense', 'Investment',
            (buyCount * otherData['stockValues'].last).toInt());
        dataController.updateCompanyData(otherData, otherData['companyName']);
        dataController.updateCompanyData(
            companyData, companyData['companyName']);
        buyCount = 0;
      } else {
        AlertMessage(
                title: 'Error',
                context: context,
                message: 'Account Balance Low')
            .getWidget();
      }
    }
  }

  void sellStocks() {
    companyData['investments'].forEach((element) {
      if (element['companyName'] == otherData['companyName']) {
        element['stocksBought'] = element['stocksBought'] - sell;
        companyData['accountBalance'] = companyData['accountBalance'] +
            (sell * otherData['stockValues'].last).toInt();
        otherData['availableStocks'] = otherData['availableStocks'] - sell;
      }
      if (element['stockBought'] <= 0) {
        companyData['investments'].remove(element);
        otherData['investors'].remove(element);
      }
    });
    addExp(300);
    addTransaction(
        'expense', 'Returns', (sell * otherData['stockValues'].last).toInt());
    dataController.updateCompanyData(companyData, companyData['companyName']);
    dataController.updateCompanyData(otherData, otherData['companyName']);
    sell = 0;
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
          child: SingleChildScrollView(child: getContent()),
        ),
      ),
    );
  }
}
