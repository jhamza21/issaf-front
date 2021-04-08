import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/views/profile.dart';
import 'package:issaf/views/providerList.dart';
import 'package:issaf/views/tickets/index.dart';

class HomeP extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomePState();
}

class _HomePState extends State<HomeP> {
  int _currentIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      ProvidersList(getTranslate(context, "PROVIDERS")),
      Tickets(),
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
                Icons.search,
                size: 20,
                color: Colors.black,
              ),
              Icon(
                Icons.bookmark,
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
