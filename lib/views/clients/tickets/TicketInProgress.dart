import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/ticket.dart';
import 'package:issaf/services/ticketService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketInProgress extends StatefulWidget {
  @override
  _TicketInProgressState createState() => _TicketInProgressState();
}

class _TicketInProgressState extends State<TicketInProgress> {
  bool _isLoading = true;
  String _error;
  List<Ticket> _tickets;

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
    } catch (error) {
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

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Card ticketCard(Ticket ticket) {
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
                      ticket.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(ticket.description),
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
                        Text("Vous avez un rendez-vous"),
                        Row(
                          children: [
                            Text(
                              ticket.date,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              " à ",
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
                  "Ticket Nᵒ",
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
                    label: Text("Annuler")),
                TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.repeat),
                    label: Text("Replanifier"))
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: circularProgressIndicator)
        : _error != null
            ? Center(
                child: Text(
                  _error,
                  style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.red,
                      fontWeight: FontWeight.w400),
                ),
              )
            : _tickets.length == 0
                ? Center(
                    child: Text(getTranslate(context, "NO_RESULT_FOUND")),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: _tickets.length,
                    itemBuilder: (context, index) {
                      return ticketCard(_tickets[index]);
                    },
                  );
  }
}
