import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/views/providers/requests.dart';

class Notifications extends StatefulWidget {
  final void Function() callback;
  Notifications(this.callback);
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Colors.black,
            tabs: [
              Tab(
                icon: Icon(Icons.transit_enterexit),
                child: Text(getTranslate(context, "RECEIVED")),
              ),
              Tab(
                icon: Icon(Icons.send),
                child: Text(getTranslate(context, "SENDED")),
              ),
            ],
          ),
          title: Text(getTranslate(context, "REQUESTS")),
        ),
        body: TabBarView(
          children: [
            Requests(true, widget.callback),
            Requests(false, widget.callback),
          ],
        ),
      ),
    );
  }
}
