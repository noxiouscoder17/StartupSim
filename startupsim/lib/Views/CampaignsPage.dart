import 'package:flutter/material.dart';
import 'package:startupsim/Controllers/DataController.dart';
import 'package:startupsim/Controllers/UserController.dart';
import 'package:startupsim/Models/models.dart';
import 'package:startupsim/Views/Accounts.dart';
import 'package:startupsim/Views/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:startupsim/Views/MailingPage.dart';
import 'package:startupsim/Widgets/Alert.dart';
import 'package:startupsim/Widgets/StadiumButton.dart';

class CampaignsPage extends StatefulWidget {
  static const String id = 'campaignsPage';
  @override
  _CampaignsPageState createState() => _CampaignsPageState();
}

class _CampaignsPageState extends State<CampaignsPage> {
  Model models = Model();
  DataController dataController = DataController();
  CollectionReference users = FirebaseFirestore.instance.collection('/users');
  CollectionReference company =
      FirebaseFirestore.instance.collection('/company');
  final currentUser = UserController().currentUser();
  Map<String, dynamic> userData, companyData;
  int _selectedIndex = 0;
  final _formKey = GlobalKey<FormState>();
  int campaignDuration,
      reputation = 0,
      estimatedCost = 0,
      billBoardCost = 0,
      sponsorshipCost = 0,
      socialMediaCost = 0,
      televisionCost = 0,
      aiCount = 0,
      uiCount = 0,
      backendCount = 0,
      cyberSecurityCount = 0,
      databaseCount = 0,
      networkCount = 0,
      totalCost = 0;
  bool billBoardCheck = false,
      sponsorshipCheck = false,
      socialMediaCheck = false,
      televisionCheck = false;
  List<String> options = [];
  DateTime now = DateTime.now();
  DateTime currentDateTime;
  Duration marketingTimeRemaining,
      recruitmentTimeRemaining,
      estimatedTime = Duration(minutes: 0);

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
    getMarketingTimeRemaining();
    getRecruitmentTimeRemaining();
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.red[400];
    }
    return Colors.red[400];
  }

  void getMarketingCost() {
    if (campaignDuration != null) {
      int bbCost = 0,
          spCost = 0,
          smCost = 0,
          tvCost = 0,
          esCost = 0,
          rep = companyData['reputation'];
      List<String> temp = [];
      if (billBoardCheck) {
        bbCost = 5000 * campaignDuration;
        temp.add('Billboard');
        rep = rep + (rep * 0.14).toInt();
      }
      if (sponsorshipCheck) {
        spCost = 10000 * campaignDuration;
        temp.add('Sponsorships');
        rep = rep + (rep * 0.22).toInt();
      }
      if (socialMediaCheck) {
        smCost = 15000 * campaignDuration;
        temp.add('Social Media');
        rep = rep + (rep * 0.35).toInt();
      }
      if (televisionCheck) {
        tvCost = 20000 * campaignDuration;
        temp.add('Television');
        rep = rep + (rep * 0.43).toInt();
      }
      esCost = bbCost + spCost + smCost + tvCost;
      estimatedCost = esCost;
      billBoardCost = bbCost;
      sponsorshipCost = spCost;
      socialMediaCost = smCost;
      televisionCost = tvCost;
      reputation = rep;
      options = temp;
    }
  }

  void getRecruitmentCost() {
    int cost = 0;
    Duration temp = Duration(minutes: 0);
    cost = (aiCount * 5) +
        (uiCount * 4) +
        (databaseCount * 4) +
        (backendCount * 5) +
        (networkCount * 6) +
        (cyberSecurityCount * 6);
    temp = Duration(
        minutes: ((aiCount +
                uiCount +
                databaseCount +
                backendCount +
                networkCount +
                cyberSecurityCount) *
            2));
    estimatedTime = temp;
    totalCost = cost;
  }

  void addExp(int exp) {
    companyData['exp'] =
        companyData['exp'] + ((exp / (companyData['level'] * 1000)) * 100);
    if (companyData['exp'] >= 100) {
      companyData['exp'] = companyData['exp'] - 100;
      companyData['level']++;
    }
  }

  void addMarketing() {
    companyData['marketing']['cost'] = estimatedCost;
    companyData['marketing']['ongoing'] = true;
    companyData['marketing']['options'] = options;
    companyData['marketing']['time'] =
        currentDateTime.add(Duration(hours: campaignDuration));
    if (reputation < 100) {
      companyData['marketing']['reputationIncreased'] = reputation;
      companyData['reputation'] = reputation;
    } else {
      companyData['marketing']['reputationIncreased'] = 100;
      companyData['reputation'] = 100;
    }
    companyData['marketing']['userBaseMultiplier'] = 2;
    companyData['userBaseMultiplier'] = 2;
    addExp(900);
  }

  void addRecruitment() {
    companyData['recruitment']['cost'] = totalCost;
    companyData['recruitment']['ongoing'] = true;
    companyData['recruitment']['aiEmployees'] = aiCount;
    companyData['recruitment']['uiEmployees'] = uiCount;
    companyData['recruitment']['databaseEmployees'] = databaseCount;
    companyData['recruitment']['backendEmployees'] = backendCount;
    companyData['recruitment']['networkEmployees'] = networkCount;
    companyData['recruitment']['cyberSecurityEmployees'] = cyberSecurityCount;
    companyData['recruitment']['time'] = currentDateTime.add(estimatedTime);
    addExp(300);
  }

  void addTransaction(String type, String purpose, int amount) {
    models.transactions['time'] = currentDateTime;
    models.transactions['type'] = type;
    models.transactions['purpose'] = purpose;
    models.transactions['amount'] = amount;
    companyData['transactions'].add(models.transactions);
  }

  String format(Duration d) {
    return d.toString().split('.').first.padLeft(8, "0");
  }

  void getMarketingTimeRemaining() {
    setState(() {
      if (companyData['marketing']['time'] != null) {
        DateTime date = companyData['marketing']['time'].toDate();
        if (date != null) {
          marketingTimeRemaining = date.difference(currentDateTime);
          if (date.isBefore(currentDateTime) ||
              date.isAtSameMomentAs(currentDateTime)) {
            companyData['marketing']['cost'] = 0;
            companyData['marketing']['ongoing'] = false;
            companyData['marketing']['options'] = [];
            companyData['marketing']['time'] = null;
            companyData['marketing']['reputationIncreased'] = 0;
            companyData['marketing']['userBaseMultiplier'] = 1;
            companyData['reputation'] = companyData['reputation'] -
                (companyData['reputation'] * 0.35).toInt();
            companyData['userBaseMultiplier'] = 1;
            dataController.updateCompanyData(
                companyData, companyData['companyName']);
          }
        } else {
          marketingTimeRemaining = Duration(hours: 0, minutes: 0, seconds: 0);
        }
      }
    });
  }

  void getRecruitmentTimeRemaining() {
    setState(() {
      if (companyData['recruitment']['time'] != null) {
        DateTime date = companyData['recruitment']['time'].toDate();
        if (date != null) {
          recruitmentTimeRemaining = date.difference(currentDateTime);
          if (date.isBefore(currentDateTime) ||
              date.isAtSameMomentAs(currentDateTime)) {
            companyData['recruitment']['cost'] = 0;
            companyData['recruitment']['ongoing'] = false;
            companyData['recruitment']['time'] = null;
            companyData['aiEmployees']['Total'] = companyData['aiEmployees']
                    ['Total'] +
                companyData['recruitment']['aiEmployees'];
            companyData['uiEmployees']['Total'] = companyData['uiEmployees']
                    ['Total'] +
                companyData['recruitment']['uiEmployees'];
            companyData['backendEmployees']['Total'] =
                companyData['backendEmployees']['Total'] +
                    companyData['recruitment']['backendEmployees'];
            companyData['cyberSecurityEmployees']['Total'] =
                companyData['cyberSecurityEmployees']['Total'] +
                    companyData['recruitment']['cyberSecurityEmployees'];
            companyData['networkEmployees']['Total'] =
                companyData['networkEmployees']['Total'] +
                    companyData['recruitment']['networkEmployees'];
            companyData['databaseEmployees']['Total'] =
                companyData['databaseEmployees']['Total'] +
                    companyData['recruitment']['databaseEmployees'];
            companyData['recruitment']['aiEmployees'] = 0;
            companyData['recruitment']['uiEmployees'] = 0;
            companyData['recruitment']['databaseEmployees'] = 0;
            companyData['recruitment']['backendEmployees'] = 0;
            companyData['recruitment']['networkEmployees'] = 0;
            companyData['recruitment']['cyberSecurityEmployees'] = 0;
            dataController.updateCompanyData(
                companyData, companyData['companyName']);
          }
        } else {
          marketingTimeRemaining = Duration(hours: 0, minutes: 0, seconds: 0);
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
        //MarketingPage
        if (companyData['marketing']['ongoing']) {
          //Ongoing Campaign
          content = Container(
            alignment: Alignment.center,
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.white,
              child: Container(
                padding: EdgeInsets.all(30),
                width: 300,
                height: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Marketing',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cost : ',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          '\$ ${companyData['marketing']['cost']}',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Time Remaining : ',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          //'${marketingTimeRemaining.inHours}.${marketingTimeRemaining.inMinutes}.${marketingTimeRemaining.inSeconds}',
                          '${format(marketingTimeRemaining)}',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          //Add Campaign
          content = Container(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Cost : ',
                          style: TextStyle(fontSize: 21),
                        ),
                        Text(
                          '\$ ${estimatedCost}',
                          style: TextStyle(fontSize: 21),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Duration : ',
                          style: TextStyle(fontSize: 21),
                        ),
                        DropdownButton(
                          items: [
                            DropdownMenuItem(
                              child: Text(
                                '2 Hours',
                                style: TextStyle(fontSize: 21),
                              ),
                              value: 2,
                            ),
                            DropdownMenuItem(
                              child: Text(
                                '4 Hours',
                                style: TextStyle(fontSize: 21),
                              ),
                              value: 4,
                            ),
                            DropdownMenuItem(
                              child: Text(
                                '8 Hours',
                                style: TextStyle(fontSize: 21),
                              ),
                              value: 8,
                            ),
                            DropdownMenuItem(
                              child: Text(
                                '12 Hours',
                                style: TextStyle(fontSize: 21),
                              ),
                              value: 12,
                            ),
                            DropdownMenuItem(
                              child: Text(
                                '16 Hours',
                                style: TextStyle(fontSize: 21),
                              ),
                              value: 16,
                            ),
                            DropdownMenuItem(
                              child: Text(
                                '24 Hours',
                                style: TextStyle(fontSize: 21),
                              ),
                              value: 24,
                            ),
                          ],
                          onChanged: (value) {
                            campaignDuration = value;
                            getMarketingCost();
                          },
                          value: campaignDuration,
                          elevation: 16,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //BillBoard
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
                                Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value: billBoardCheck,
                                  onChanged: (value) {
                                    setState(() {
                                      billBoardCheck = value;
                                      getMarketingCost();
                                    });
                                  },
                                ),
                                Text(
                                  'Billboard',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Effective :'),
                                    Text('10-15%'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Cost :'),
                                    Text('\$ ${billBoardCost}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        //Sponsorship
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
                                Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value: sponsorshipCheck,
                                  onChanged: (value) {
                                    setState(() {
                                      sponsorshipCheck = value;
                                      getMarketingCost();
                                    });
                                  },
                                ),
                                Text(
                                  'Sponsorships',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Effective :'),
                                    Text('20-25%'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Cost :'),
                                    Text('\$ ${sponsorshipCost}'),
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
                        //Social Media
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
                                Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value: socialMediaCheck,
                                  onChanged: (value) {
                                    setState(() {
                                      socialMediaCheck = value;
                                      getMarketingCost();
                                    });
                                  },
                                ),
                                Text(
                                  'Social Media',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Effective :'),
                                    Text('30-35%'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Cost :'),
                                    Text('\$ ${socialMediaCost}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        //Television
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
                                Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value: televisionCheck,
                                  onChanged: (value) {
                                    setState(() {
                                      televisionCheck = value;
                                      getMarketingCost();
                                    });
                                  },
                                ),
                                Text(
                                  'Television',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Effective :'),
                                    Text('40-45%'),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Cost :'),
                                    Text('\$ ${televisionCost}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    StadiumButton(
                      onPressed: () {
                        _formKey.currentState.save();
                        setState(() async {
                          getMarketingCost();
                          if (!billBoardCheck &
                              !sponsorshipCheck &
                              !socialMediaCheck &
                              !televisionCheck) {
                            AlertMessage(
                              message: 'Select atleast one mode',
                              title: 'Error',
                              context: context,
                            ).getWidget();
                          } else {
                            if (campaignDuration == null) {
                              AlertMessage(
                                message: 'Select a duration',
                                title: 'Error',
                                context: context,
                              ).getWidget();
                            } else {
                              if (estimatedCost <=
                                  companyData['accountBalance']) {
                                addTransaction(
                                    'expense', 'Operations', estimatedCost);
                                addMarketing();
                                companyData['accountBalance'] =
                                    companyData['accountBalance'] -
                                        estimatedCost;
                                dataController.updateCompanyData(
                                    companyData, companyData['companyName']);
                              } else {
                                AlertMessage(
                                  message: 'Account balance too low',
                                  title: 'Error',
                                  context: context,
                                ).getWidget();
                              }
                            }
                          }
                        });
                      },
                      width: 200,
                      height: 50,
                      color: Colors.red[400],
                      text: 'Start Campaign',
                    ).getWidget(),
                  ],
                ),
              ),
            ),
          );
        }
      } else {
        //RecruitmentPage
        if (companyData['recruitment']['ongoing']) {
          //Ongoing Campaign
          content = Container(
            alignment: Alignment.center,
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.white,
              child: Container(
                padding: EdgeInsets.all(30),
                width: 300,
                height: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Recruitment',
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cost : ',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          '\$ ${companyData['recruitment']['cost']}',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Time Remaining : ',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          //'${marketingTimeRemaining.inHours}.${marketingTimeRemaining.inMinutes}.${marketingTimeRemaining.inSeconds}',
                          '${format(recruitmentTimeRemaining)}',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          //Add Campaign
          content = Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(top: 40),
            width: double.infinity,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 250,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cost : ',
                        style: TextStyle(fontSize: 21),
                      ),
                      Text(
                        '\$ ${totalCost}',
                        style: TextStyle(fontSize: 21),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 250,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Duration : ',
                        style: TextStyle(fontSize: 21),
                      ),
                      Text(
                        '${format(estimatedTime)}',
                        style: TextStyle(fontSize: 21),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 10,
                      child: Container(
                        width: 150,
                        height: 120,
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
                                  size: 20,
                                ),
                                Text(
                                  'AI',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Employees :'),
                                Text('$aiCount'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Cost :'),
                                Text('\$ ${aiCount * 5}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (aiCount > 0) {
                                        aiCount--;
                                      }
                                      getRecruitmentCost();
                                    });
                                  },
                                  child: Icon(Icons.remove),
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red[400]),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (aiCount < 1000) {
                                        aiCount++;
                                      }
                                      getRecruitmentCost();
                                    });
                                  },
                                  child: Icon(Icons.add),
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
                        height: 120,
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
                                  size: 20,
                                ),
                                Text(
                                  'UI',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Employees :'),
                                Text('$uiCount'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Cost :'),
                                Text('\$ ${uiCount * 4}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (uiCount > 0) {
                                        uiCount--;
                                      }
                                      getRecruitmentCost();
                                    });
                                  },
                                  child: Icon(Icons.remove),
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red[400]),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (uiCount < 1000) {
                                        uiCount++;
                                      }
                                      getRecruitmentCost();
                                    });
                                  },
                                  child: Icon(Icons.add),
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
                        height: 120,
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
                                  size: 20,
                                ),
                                Text(
                                  'Backend',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Employees :'),
                                Text('$backendCount'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Cost :'),
                                Text('\$ ${backendCount * 5}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (backendCount > 0) {
                                        backendCount--;
                                      }
                                      getRecruitmentCost();
                                    });
                                  },
                                  child: Icon(Icons.remove),
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red[400]),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (backendCount < 1000) {
                                        backendCount++;
                                      }
                                      getRecruitmentCost();
                                    });
                                  },
                                  child: Icon(Icons.add),
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
                        height: 120,
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
                                  size: 20,
                                ),
                                Text(
                                  'Security',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Employees :'),
                                Text('$cyberSecurityCount'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Cost :'),
                                Text('\$ ${cyberSecurityCount * 6}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (cyberSecurityCount > 0) {
                                        cyberSecurityCount--;
                                      }
                                      getRecruitmentCost();
                                    });
                                  },
                                  child: Icon(Icons.remove),
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red[400]),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (cyberSecurityCount < 1000) {
                                        cyberSecurityCount++;
                                      }
                                      getRecruitmentCost();
                                    });
                                  },
                                  child: Icon(Icons.add),
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
                        height: 120,
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
                                  size: 20,
                                ),
                                Text(
                                  'Database',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Employees :'),
                                Text('$databaseCount'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Cost :'),
                                Text('\$ ${databaseCount * 4}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (databaseCount > 0) {
                                        databaseCount--;
                                      }
                                      getRecruitmentCost();
                                    });
                                  },
                                  child: Icon(Icons.remove),
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red[400]),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (databaseCount < 1000) {
                                        databaseCount++;
                                      }
                                      getRecruitmentCost();
                                    });
                                  },
                                  child: Icon(Icons.add),
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
                        height: 120,
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
                                  size: 20,
                                ),
                                Text(
                                  'Network',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Employees :'),
                                Text('$networkCount'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Cost :'),
                                Text('\$ ${networkCount * 6}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (networkCount > 0) {
                                        networkCount--;
                                      }
                                      getRecruitmentCost();
                                    });
                                  },
                                  child: Icon(Icons.remove),
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.red[400]),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (networkCount < 1000) {
                                        networkCount++;
                                      }
                                      getRecruitmentCost();
                                    });
                                  },
                                  child: Icon(Icons.add),
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
                SizedBox(
                  height: 20,
                ),
                StadiumButton(
                    width: 200,
                    height: 50,
                    color: Colors.red[400],
                    text: 'Start Recruitment',
                    onPressed: () {
                      setState(() {
                        getMarketingCost();
                        if ((aiCount +
                                uiCount +
                                backendCount +
                                cyberSecurityCount +
                                databaseCount +
                                networkCount) ==
                            0) {
                          AlertMessage(
                            message: 'Hire atleast one employee',
                            title: 'Error',
                            context: context,
                          ).getWidget();
                        } else {
                          if (totalCost <= companyData['accountBalance']) {
                            addTransaction('expense', 'Operations', totalCost);
                            addRecruitment();
                            companyData['accountBalance'] =
                                companyData['accountBalance'] - totalCost;
                            dataController.updateCompanyData(
                                companyData, companyData['companyName']);
                          } else {
                            AlertMessage(
                              message: 'Account balance too low',
                              title: 'Error',
                              context: context,
                            ).getWidget();
                          }
                        }
                      });
                    }).getWidget()
              ],
            ),
          );
        }
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
              icon: Icon(Icons.request_page),
              label: 'Marketing',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_add),
              label: 'Recruitment',
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
