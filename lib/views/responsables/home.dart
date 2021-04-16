import 'dart:convert';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:issaf/models/request.dart';
import 'package:issaf/services/requestService.dart';
import 'package:issaf/views/responsables/handleService.dart';
import 'package:issaf/views/responsables/notifications.dart';
import 'package:issaf/views/responsables/serviceDetails.dart';
import 'package:issaf/views/shared/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  bool _notificationOn = false;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  void _fetchRequests() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      final response = await RequestService()
          .fetchReceivedRequests(prefs.getString('token'));
      assert(response.statusCode == 200);
      final jsonData = json.decode(response.body);
      setState(() {
        _notificationOn = Request.listFromJson(jsonData).length > 0;
      });
    } catch (e) {}
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      HandleService(),
      Notifications(_fetchRequests),
      ServiceDetails(),
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
                Icons.home,
                size: 20,
                color: Colors.black,
              ),
              Stack(
                children: [
                  Icon(
                    Icons.notifications,
                    size: 20,
                    color: Colors.black,
                  ),
                  _notificationOn
                      ? new Positioned(
                          top: 0.0,
                          right: 0.0,
                          child: new Icon(
                            Icons.brightness_1,
                            size: 10.0,
                            color: Colors.red,
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
              Icon(
                Icons.info,
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
