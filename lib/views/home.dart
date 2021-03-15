import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/redux/store.dart';
import 'package:issaf/redux/users/actions.dart';
import 'package:issaf/views/providerList.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  void onTabTapped(int index) {
    if (index == 2) {
      Redux.store.dispatch(logoutUserAction);
    } else
      setState(() {
        _currentIndex = index;
      });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      ProvidersList(false, getTranslate(context, "PROVIDERS")),
      ProvidersList(true, getTranslate(context, "PROVIDERS"))
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
                Icons.star,
                size: 20,
                color: Colors.black,
              ),
              Icon(
                Icons.exit_to_app,
                size: 20,
                color: Colors.black,
              )
            ]),
        body: _children[_currentIndex]);
  }
}
