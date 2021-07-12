import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startupsim/Controllers/DataController.dart';
import 'package:startupsim/Controllers/UserController.dart';
import 'package:startupsim/Models/models.dart';
import 'package:startupsim/Views/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountPage extends StatefulWidget {
  static const String id = 'accountPage';
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int _selectedIndex = 0;
  DateTime now = DateTime.now();
  DateTime currentDateTime;
  Model models = Model();
  DataController dataController = DataController();
  CollectionReference users = FirebaseFirestore.instance.collection('/users');
  CollectionReference company =
      FirebaseFirestore.instance.collection('/company');
  final currentUser = UserController().currentUser();
  Map<String, dynamic> userData, companyData, productData;
  List<Card> incomeList = [Card()], expenseList = [Card()];
  IconData sortIcon = Icons.arrow_upward;
  bool isReverse = false;
  Color totalColor = Colors.green;
  int totalExpenses = 0,
      totalIncome = 0,
      operationIncome = 0,
      operationExpense = 0,
      investmentExpense = 0,
      returnIncome = 0,
      total = 0;

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
      getTransactionList();
    }
  }

  void getTransactionList() {
    List<Card> income = [], expense = [];
    int tempExpense = 0,
        tempIncome = 0,
        tempOperationIncome = 0,
        tempOperationExpense = 0,
        tempInvestmentExpense = 0,
        tempReturnIncome = 0;
    if (companyData['transactions'].isNotEmpty) {
      companyData['transactions'].forEach((element) {
        if (element['type'] == 'expense') {
          tempExpense = tempExpense + element['amount'];
          if (element['purpose'] == 'Operations') {
            tempOperationExpense = tempOperationExpense + element['amount'];
          }
          if (element['purpose'] == 'Investment') {
            tempInvestmentExpense = tempInvestmentExpense + element['amount'];
          }
          DateTime date = element['time'].toDate();
          expense.add(Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              alignment: Alignment.center,
              width: 350,
              height: 70,
              padding: EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time),
                      Text(
                        '${date.day}.${date.month}.${date.year} : ${date.hour}.${date.minute}.${date.second}',
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timeline),
                      Text(
                        '${element['purpose']}',
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.monetization_on),
                      Text(
                        '\$ ${element['amount']}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ));
        } else {
          tempIncome = tempIncome + element['amount'];
          if (element['purpose'] == 'Operations') {
            tempOperationIncome = tempOperationIncome + element['amount'];
          }
          if (element['purpose'] == 'Returns') {
            tempReturnIncome = tempReturnIncome + element['amount'];
          }
          DateTime date = element['time'].toDate();
          income.add(Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              alignment: Alignment.center,
              width: 350,
              height: 70,
              padding: EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time),
                      Text(
                        '${date.day}.${date.month}.${date.year} : ${date.hour}.${date.minute}.${date.second}',
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timeline),
                      Text(
                        '${element['purpose']}',
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.monetization_on),
                      Text(
                        '\$ ${element['amount']}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ));
        }
      });
    }
    if (income.isEmpty) {
      income.add(Card(
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
    if (expense.isEmpty) {
      expense.add(Card(
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
    if (isReverse) {
      incomeList = income.reversed.toList();
      expenseList = expense.reversed.toList();
    } else {
      incomeList = income;
      expenseList = expense;
    }
    totalExpenses = tempExpense;
    totalIncome = tempIncome;
    operationIncome = tempOperationIncome;
    operationExpense = tempOperationExpense;
    investmentExpense = tempInvestmentExpense;
    returnIncome = tempReturnIncome;
    total = totalIncome - totalExpenses;
    if (total < 0) {
      totalColor = Colors.red;
    } else {
      totalColor = Colors.green;
    }
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
              icon: Icon(Icons.add),
              label: 'Income',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.remove),
              label: 'Expense',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_rounded),
              label: 'Summary',
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.only(top: 40, right: 20, left: 20),
            child: Column(
              children: [
                Text(
                  '${companyData['companyName']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                  ),
                ),
                Text(
                  '\$ ${companyData['accountBalance']}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                getContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container getContent() {
    Container content;
    if (_selectedIndex == 0) {
      //Income
      content = Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Income Transactions',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                IconButton(
                  icon: Icon(sortIcon),
                  onPressed: () {
                    setState(() {
                      if (isReverse == true) {
                        isReverse = false;
                        sortIcon = Icons.arrow_upward;
                      } else {
                        isReverse = true;
                        sortIcon = Icons.arrow_downward;
                      }
                    });
                  },
                ),
              ],
            ),
            Container(
              width: 400,
              height: 364,
              child: SingleChildScrollView(
                child: Column(
                  children: incomeList,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (_selectedIndex == 1) {
      //Expenses
      content = Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Expense Transactions',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                IconButton(
                  icon: Icon(sortIcon),
                  onPressed: () {
                    setState(() {
                      if (isReverse) {
                        isReverse = false;
                        sortIcon = Icons.arrow_upward;
                      } else {
                        isReverse = true;
                        sortIcon = Icons.arrow_downward;
                      }
                    });
                  },
                ),
              ],
            ),
            Container(
              width: 400,
              height: 364,
              child: SingleChildScrollView(
                child: Column(
                  children: expenseList,
                ),
              ),
            )
          ],
        ),
      );
    } else {
      //Summary
      content = Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(top: 20),
        width: 300,
        height: 400,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 10,
                  child: Container(
                    width: 132,
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Expenses'),
                        Text(
                          '\$ ${totalExpenses}',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 10,
                  child: Container(
                    width: 132,
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Income'),
                        Text(
                          '\$ ${totalIncome}',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            Card(
              elevation: 10,
              child: Container(
                width: 275,
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Total'),
                    Text(
                      '\$ ${total}',
                      style: TextStyle(
                        color: totalColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 10,
                  child: Container(
                    width: 132,
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Operations Cost'),
                        Text(
                          '\$ ${operationExpense}',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 10,
                  child: Container(
                    width: 132,
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Operations Profit'),
                        Text(
                          '\$ ${operationIncome}',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 10,
                  child: Container(
                    width: 132,
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Investment'),
                        Text(
                          '\$ ${investmentExpense}',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 10,
                  child: Container(
                    width: 132,
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Returns'),
                        Text(
                          '\$ ${returnIncome}',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    }
    return content;
  }
}
