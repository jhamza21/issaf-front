import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:issaf/views/providers/notifications.dart';
import 'package:issaf/views/providers/profile.dart';
import 'package:issaf/views/providers/serviceList.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      ServiceList("SAFF"),
      Notifications(),
      Profile()
    ];
    return new Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
            backgroundColor: Colors.white,
            color: Colors.orange,
            onTap: onTabTapped,
            height: 50,
            animationDuration: Duration(milliseconds: 200),
            animationCurve: Curves.bounceInOut,
            index: _currentIndex,
            items: <Widget>[
              Icon(
                Icons.list,
                size: 20,
                color: Colors.black,
              ),
              Icon(
                Icons.notifications,
                size: 20,
                color: Colors.black,
              ),
              Icon(
                Icons.account_circle,
                size: 20,
                color: Colors.black,
              )
            ]),
        body: _children[_currentIndex]);
  }
}
