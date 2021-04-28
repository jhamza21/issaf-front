import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:issaf/redux/store.dart';
import 'package:issaf/views/clients/home.dart' as Clients;
import 'package:issaf/views/providers/home.dart' as Providers;
import 'package:issaf/views/responsables/home.dart' as Responsibles;

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          if (state.userState.role == "CLIENT")
            return Clients.Home(state.userState);
          else if (state.userState.role == "ADMIN")
            return Providers.Home(state.userState);
          else
            return Responsibles.Home(state.userState);
        });
  }
}
