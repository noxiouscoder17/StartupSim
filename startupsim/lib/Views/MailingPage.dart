import 'package:flutter/material.dart';
import 'package:startupsim/Views/HomePage.dart';

class MailingPage extends StatefulWidget {
  static const String id = 'mailingPage';

  @override
  _MailingPageState createState() => _MailingPageState();
}

class _MailingPageState extends State<MailingPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print(_selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                '9',
                style: TextStyle(fontSize: 10),
              ),
            ),
            title: Container(
              height: 15,
              width: (76 / 100) * 300,
              color: Colors.green,
            ),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.red[400],
          title: TextButton(
            onPressed: () {},
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
                  '\$ 10000',
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
              onPressed: () {},
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
              icon: Icon(Icons.inbox),
              label: 'Inbox',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.outbox),
              label: 'Outbox',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.create),
              label: 'Compose',
            ),
          ],
        ),
      ),
    );
  }
}
