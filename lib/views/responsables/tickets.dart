import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/service.dart';
import 'package:issaf/views/responsables/bookTicket.dart';
import 'package:issaf/views/responsables/ticketsInProgress.dart';
import 'package:issaf/views/responsables/ticketsOld.dart';

class Tickets extends StatefulWidget {
  final void Function(int) callback;
  final Service service;
  Tickets(this.callback, this.service);
  @override
  _TicketsState createState() => _TicketsState();
}

class _TicketsState extends State<Tickets> {
  int _currentIndex = 0;

  bool _showAppBar = true;

  switchAppBar(bool x) {
    setState(() {
      _showAppBar = x;
    });
  }

  void changePage(int i) {
    _showAppBar = _currentIndex == 0 ? false : true;
    setState(() {
      _currentIndex = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: mainBoxDecoration,
        child: Scaffold(
          appBar: _showAppBar
              ? AppBar(
                  elevation: 0,
                  title: Text(getTranslate(context, 'MY_TICKETS')),
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(Icons.navigate_before),
                    onPressed: () => widget.callback(0),
                  ),
                  actions: [
                    IconButton(
                        onPressed: () => changePage(1), icon: Icon(Icons.add))
                  ],
                  bottom: TabBar(
                    indicatorColor: Colors.white,
                    tabs: [
                      Tab(child: Text(getTranslate(context, "IN_PROGRESS"))),
                      Tab(child: Text(getTranslate(context, "HISTORICAL"))),
                    ],
                  ),
                )
              : null,
          body: _currentIndex == 0
              ? TabBarView(
                  children: [
                    TicketsInProgress(widget.service.id, switchAppBar),
                    TicketsOld(widget.service.id)
                  ],
                )
              : BookTicket(widget.service, changePage, null),
        ),
      ),
    );
  }
}
