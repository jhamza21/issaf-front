import 'package:flutter/material.dart';
import 'package:issaf/views/providers/requests.dart';

class Notifications extends StatefulWidget {
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
                child: Text("Reçues"),
              ),
              Tab(
                icon: Icon(Icons.send),
                child: Text("Envoyées"),
              ),
            ],
          ),
          title: Text('Invitations'),
        ),
        body: TabBarView(
          children: [
            Requests(true),
            Requests(false),
          ],
        ),
      ),
    );
  }
}
