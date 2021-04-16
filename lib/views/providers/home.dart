import 'dart:convert';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:issaf/models/provider.dart' as ModelProvider;
import 'package:issaf/models/request.dart';
import 'package:issaf/redux/store.dart';
import 'package:issaf/redux/users/actions.dart';
import 'package:issaf/redux/users/state.dart';
import 'package:issaf/services/provideService.dart';
import 'package:issaf/services/requestService.dart';
import 'package:issaf/views/providers/notifications.dart';
import 'package:issaf/views/providers/addUpdateProvider.dart';
import 'package:issaf/views/providers/serviceList.dart';
import 'package:issaf/views/shared/profile.dart';
import 'package:issaf/views/waitingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  ModelProvider.Provider _provider;
  int _currentIndex = 0;
  bool _notificationOn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProvider();
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

  void _fetchProvider() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      final response =
          await ProviderService().fetchProviderUser(prefs.getString('token'));
      assert(response.statusCode == 200);
      final jsonData = json.decode(response.body);
      setState(() {
        _provider = jsonData["id"] == null
            ? null
            : ModelProvider.Provider.fromJson(jsonData);
        _currentIndex = _provider == null ? 2 : 0;
        _isLoading = false;
      });
    } catch (error) {
      var prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', null);
      Redux.store.dispatch(
        SetUserStateAction(
          UserState(
            isLoggedIn: false,
            user: null,
          ),
        ),
      );
    }
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void setProvider(ModelProvider.Provider prov) {
    setState(() {
      _provider = prov;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      ServiceList(_provider),
      Notifications(),
      AddUpdateProvider(_provider, setProvider),
      Profile(),
    ];
    return _isLoading
        ? WaitingScreen()
        : new Scaffold(
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
                    Icons.settings,
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
