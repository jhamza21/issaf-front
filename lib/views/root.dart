import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:issaf/models/user.dart';
import 'package:issaf/redux/store.dart';
import 'package:issaf/redux/users/actions.dart';
import 'package:issaf/redux/users/state.dart';
import 'package:issaf/services/userService.dart';
import 'package:issaf/views/shared/home.dart';
import 'package:issaf/views/waitingScreen.dart';
import 'package:issaf/views/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RootPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
  }

  //check token is valid
  Future<void> _checkLoggedInUser() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      print(prefs.getString('token'));
      final response = await UserService().checkToken(prefs.getString('token'));
      final jsonData = json.decode(response.body);
      assert(jsonData["id"] != null);
      Redux.store.dispatch(
        SetUserStateAction(
          UserState(
              isLoggedIn: true,
              user: User.fromJson(jsonData),
              role: prefs.getString("role") != null
                  ? prefs.getString("role")
                  : "CLIENT"),
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      //disconnect
      Redux.store.dispatch(SetUserStateAction(UserState(isLoggedIn: false)));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        if (_isLoading)
          return WaitingScreen();
        else if (state.userState.isLoggedIn)
          return Home();
        else
          return Welcome();
      },
    );
  }
}
