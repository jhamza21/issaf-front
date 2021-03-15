import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:issaf/redux/store.dart';
import 'package:issaf/redux/users/actions.dart';
import 'package:issaf/views/authentification.dart';
import 'package:issaf/views/home.dart';
import 'package:issaf/views/waitingScreen.dart';

class RootPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  void initState() {
    super.initState();
    _onCheckLoggedInUser();
  }

  void _onCheckLoggedInUser() {
    Redux.store.dispatch(checkLoggedInUserAction(Redux.store));
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        if (state.userState.isCheckingLogin) {
          return WaitingScreen();
        } else if (state.userState.isLoggedIn) {
          return Home();
        } else {
          return LoginSignUp();
        }
      },
    );
  }
}
