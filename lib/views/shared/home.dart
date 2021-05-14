import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:issaf/constants.dart';
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
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      FlutterRingtonePlayer.playNotification();
      RemoteNotification notification = message.notification;
      showNotification(notification.title, notification.body);
    });
  }

  void showNotification(String title, String body) {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(getTranslate(context, "OK")))
          ],
          title: Wrap(
            children: [
              Icon(Icons.notifications, size: 30),
              Text("  " + title),
            ],
          ),
          content: Text(body),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          if (state.userState.role == "CLIENT")
            return Clients.Home(state.userState);
          else if (state.userState.role == "ADMIN_SERVICE")
            return Providers.Home(state.userState);
          else
            return Responsibles.Home(state.userState);
        });
  }
}
