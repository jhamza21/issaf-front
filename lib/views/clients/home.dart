import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/redux/users/state.dart';
import 'package:issaf/views/shared/profile.dart';
import 'package:issaf/views/clients/providers.dart';
import 'package:issaf/views/clients/tickets.dart';

class Home extends StatefulWidget {
  final UserState userState;
  Home(this.userState);
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
      ProvidersList(getTranslate(context, "PROVIDERS"), widget.userState),
      Tickets(),
      Profile(widget.userState)
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
