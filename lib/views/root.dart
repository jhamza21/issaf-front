import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:issaf/redux/store.dart';
import 'package:issaf/redux/users/actions.dart';
import 'package:issaf/views/clients/home.dart' as Client;
import 'package:issaf/views/providers/home.dart' as Providers;
import 'package:issaf/views/responsables/home.dart' as Responsable;
import 'package:issaf/views/waitingScreen.dart';
import 'package:issaf/views/welcome.dart';

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
          if (state.userState.user.role == "CLIENT")
            return Client.Home();
          else if (state.userState.user.role == "ADMIN_SERVICE")
            return Providers.Home();
          else
            return Responsable.Home();
        } else {
          return Welcome();
        }
      },
    );
  }
}
