import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/views/tickets/TicketInProgress.dart';
import 'package:issaf/views/tickets/TicketOld.dart';

class Tickets extends StatefulWidget {
  @override
  _TicketsState createState() => _TicketsState();
}

class _TicketsState extends State<Tickets> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: mainBoxDecoration,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text(getTranslate(context, 'MY_TICKETS')),
            centerTitle: true,
            bottom: TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(child: Text(getTranslate(context, "IN_PROGRESS"))),
                Tab(child: Text(getTranslate(context, "HISTORICAL"))),
              ],
            ),
          ),
          body: TabBarView(
            children: [TicketInProgress(), TicketOld()],
          ),
        ),
      ),
    );
  }
}
