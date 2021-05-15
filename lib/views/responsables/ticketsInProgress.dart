import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/ticket.dart';
import 'package:issaf/services/ticketService.dart';
import 'package:issaf/views/responsables/bookTicket.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketsInProgress extends StatefulWidget {
  final int serviceId;
  final void Function(bool) switchAppBar;
  TicketsInProgress(this.serviceId, this.switchAppBar);
  @override
  _TicketsInProgressState createState() => _TicketsInProgressState();
}

class _TicketsInProgressState extends State<TicketsInProgress> {
  bool _isLoading = true, _isHandlingTicket = false;
  List<Ticket> _tickets = [];
  Ticket _selectedTicket;
  int _currentIndex = 0;

  changePage(int i) {
    if (i == 0) {
      widget.switchAppBar(true);
      _fetchTickets();
    } else
      widget.switchAppBar(false);
    setState(() {
      _currentIndex = i;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  void _fetchTickets() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var prefs = await SharedPreferences.getInstance();
      final response = await TicketService()
          .fetchOperatorTickets(prefs.getString('token'), widget.serviceId);
      assert(response.statusCode == 200);
      final jsonData = json.decode(response.body);
      _tickets = Ticket.listFromJson(jsonData);
      _tickets.removeWhere((element) => element.status != "IN_PROGRESS");
      _tickets = _tickets.reversed.toList();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      final snackBar = SnackBar(
        content: Text(getTranslate(context, "ERROR_SERVER")),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _deleteTicket(int id) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: RichText(
              text: TextSpan(
            children: [
              WidgetSpan(child: Icon(Icons.remove_circle)),
              TextSpan(
                  text: "  " + getTranslate(context, "DELETE_TICKET") + " ?",
                  style: TextStyle(color: Colors.black, fontSize: 18)),
            ],
          )),
          content:
              new Text(getTranslate(context, "DELETE_TICKET_CONFIRMATION")),
          actions: <Widget>[
            // ignore: deprecated_member_use
            new FlatButton(
              child: new Text(getTranslate(context, "NO")),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            // ignore: deprecated_member_use
            new FlatButton(
              child: new Text(getTranslate(context, "YES")),
              onPressed: () async {
                try {
                  Navigator.of(dialogContext).pop();
                  setState(() {
                    _isHandlingTicket = true;
                  });
                  var prefs = await SharedPreferences.getInstance();
                  final response = await TicketService()
                      .deleteTicket(prefs.getString('token'), id);
                  assert(response.statusCode == 204);
                  _tickets.removeWhere((element) => element.id == id);
                  final snackBar = SnackBar(
                    content: Text(getTranslate(context, "SUCCESS_DELETE")),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  setState(() {
                    _isHandlingTicket = false;
                  });
                } catch (error) {
                  final snackBar = SnackBar(
                    content: Text(getTranslate(context, "ERROR_SERVER")),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  setState(() {
                    _isHandlingTicket = false;
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
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Container(
                          height: 30,
                          width: 30,
                          child: Image.asset(
                            'assets/images/alarm.gif',
                          )),
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(getTranslate(context, "TICKET_MSG_RESPONSIBLE")),
                        Text(
                          ticket.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Divider(),
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
                    ),
                    Icon(ticket.notifications.length != 0
                        ? Icons.notifications_on
                        : Icons.notifications_off)
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
                    onPressed: _isHandlingTicket
                        ? null
                        : () => _deleteTicket(ticket.id),
                    icon: Icon(Icons.remove_circle),
                    label: Text(getTranslate(context, "CANCEL"))),
                TextButton.icon(
                    onPressed: _isHandlingTicket
                        ? null
                        : () => {
                              _selectedTicket = ticket,
                              changePage(1),
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

  @override
  Widget build(BuildContext context) {
    return _currentIndex == 1
        ? BookTicket(_selectedTicket.service, changePage, _selectedTicket)
        : _isLoading
            ? Center(child: circularProgressIndicator)
            : _tickets.length == 0
                ? Center(
                    child: Text(getTranslate(context, "NO_RESULT_FOUND")),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: _tickets.length,
                    itemBuilder: (context, index) {
                      return ticketCardInProgress(_tickets[index]);
                    },
                  );
  }
}
