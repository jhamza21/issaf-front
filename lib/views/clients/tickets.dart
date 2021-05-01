import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/ticket.dart';
import 'package:issaf/services/ticketService.dart';
import 'package:issaf/views/clients/bookTicket.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tickets extends StatefulWidget {
  @override
  _TicketsState createState() => _TicketsState();
}

class _TicketsState extends State<Tickets> {
  bool _isLoading = true;
  String _error;
  List<Ticket> _tickets;
  int _currentIndex = 0;
  Ticket _selectedTicket;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  void changePage(int i) {
    setState(() {
      _currentIndex = i;
    });
  }

  void _fetchTickets() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      final response =
          await TicketService().fetchTickets(prefs.getString('token'));
      assert(response.statusCode == 200);
      final jsonData = json.decode(response.body);
      _tickets = Ticket.listFromJson(jsonData);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = getTranslate(context, "ERROR_SERVER");
      });
    }
  }

  void _deleteTicket(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(getTranslate(context, "DELETE") + "?"),
          content:
              new Text(getTranslate(context, "DELETE_CONFIRMATION") + " ?"),
          actions: <Widget>[
            // ignore: deprecated_member_use
            new FlatButton(
              child: new Text(getTranslate(context, "NO")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // ignore: deprecated_member_use
            new FlatButton(
              child: new Text(getTranslate(context, "YES")),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  setState(() {
                    _isLoading = true;
                  });
                  var prefs = await SharedPreferences.getInstance();
                  final response = await TicketService()
                      .deleteTicket(prefs.getString('token'), id);
                  assert(response.statusCode == 204);
                  _fetchTickets();
                  final snackBar = SnackBar(
                    content: Text(getTranslate(context, "SUCCESS_DELETE")),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  setState(() {
                    _isLoading = false;
                  });
                } catch (error) {
                  final snackBar = SnackBar(
                    content: Text(getTranslate(context, "FAIL_DELETE")),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Card ticketCardInProgress(Ticket ticket) {
    return Card(
      child: Column(
        children: [
          Container(
            height: 42,
            color: Colors.orange[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      ticket.service.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(ticket.service.description),
                  ],
                ),
              ],
            ),
          ),
          Container(
              color: Colors.white,
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                        height: 80,
                        width: 50,
                        child: Image.asset(
                          'assets/images/alarm.gif',
                        )),
                    Column(
                      children: [
                        Text(getTranslate(context, "TICKET_MSG")),
                        Row(
                          children: [
                            Text(
                              ticket.date,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              getTranslate(context, "A"),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              ticket.time.substring(0, 5),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                Text(
                  getTranslate(context, "TICKET_NUMBER"),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                Text(
                  ticket.number.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50.0),
                ),
              ])),
          Container(
            color: Colors.orange[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                    onPressed: () {
                      _deleteTicket(ticket.id);
                    },
                    icon: Icon(Icons.remove_circle),
                    label: Text(getTranslate(context, "CANCEL"))),
                TextButton.icon(
                    onPressed: () {
                      _selectedTicket = ticket;
                      changePage(1);
                    },
                    icon: Icon(Icons.restore_rounded),
                    label: Text(getTranslate(context, "RESCHEDULE"))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Card ticketCardOld(Ticket ticket) {
    return Card(
      color: Colors.white70,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(
            ticket.service.title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            getTranslate(context,
                ticket.status == "DONE" ? "TICKET_DONE" : "TICKET_UNDONE"),
            style: TextStyle(fontSize: 13),
          ),
          leading: IconButton(
              icon: Icon(
                Icons.delete_rounded,
                color: Colors.red,
              ),
              onPressed: () {
                _deleteTicket(ticket.id);
              }),
          trailing: Icon(
            Icons.circle,
            size: 15,
            color: ticket.status == "DONE" ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  Widget ticketsInProgress() {
    List<Ticket> _ticketsInProgress = _tickets;
    if (_ticketsInProgress != null)
      _ticketsInProgress
          .removeWhere((element) => element.status != "IN_PROGRESS");
    return _isLoading
        ? Center(child: circularProgressIndicator)
        : _error != null
            ? Center(
                child: Text(
                  _error,
                  style: TextStyle(fontSize: 14.0, color: Colors.red),
                ),
              )
            : _ticketsInProgress.length == 0
                ? Center(
                    child: Text(getTranslate(context, "NO_RESULT_FOUND")),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: _ticketsInProgress.length,
                    itemBuilder: (context, index) {
                      return ticketCardInProgress(_ticketsInProgress[index]);
                    },
                  );
  }

  Widget ticketsOld() {
    List<Ticket> _ticketsOld = _tickets;
    if (_ticketsOld != null)
      _ticketsOld.removeWhere((element) => element.status == "IN_PROGRESS");
    return _isLoading
        ? Center(child: circularProgressIndicator)
        : _error != null
            ? Center(
                child: Text(
                  _error,
                  style: TextStyle(fontSize: 14.0, color: Colors.red),
                ),
              )
            : _ticketsOld.length == 0
                ? Center(
                    child: Text(getTranslate(context, "NO_RESULT_FOUND")),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: _ticketsOld.length,
                    itemBuilder: (context, index) {
                      return ticketCardOld(_ticketsOld[index]);
                    },
                  );
  }

  @override
  Widget build(BuildContext context) {
    return _currentIndex == 0
        ? DefaultTabController(
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
                  children: [ticketsInProgress(), ticketsOld()],
                ),
              ),
            ),
          )
        : BookTicket(_selectedTicket.service, changePage, _fetchTickets);
  }
}
