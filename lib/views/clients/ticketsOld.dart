import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/ticket.dart';
import 'package:issaf/services/ticketService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketsOld extends StatefulWidget {
  @override
  _TicketsOldState createState() => _TicketsOldState();
}

class _TicketsOldState extends State<TicketsOld> {
  bool _isLoading = true, _isHandlingTicket = false;
  List<Ticket> _tickets = [];

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
      final response =
          await TicketService().fetchTickets(prefs.getString('token'));
      assert(response.statusCode == 200);
      final jsonData = json.decode(response.body);
      _tickets = Ticket.listFromJson(jsonData);
      _tickets.removeWhere((element) => element.status == "IN_PROGRESS");
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
                try {
                  setState(() {
                    _isHandlingTicket = true;
                  });
                  Navigator.of(context).pop();
                  var prefs = await SharedPreferences.getInstance();
                  final response = await TicketService()
                      .deleteTicket(prefs.getString('token'), id);
                  assert(response.statusCode == 204);
                  _tickets.removeWhere((element) => element.id == id);
                  setState(() {
                    _tickets = _tickets;
                  });
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
            ticket.date +
                getTranslate(context, "A") +
                ticket.time.substring(0, 5),
            style: TextStyle(fontSize: 13),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.delete_rounded,
              color: Colors.red,
            ),
            onPressed:
                _isHandlingTicket ? null : () => _deleteTicket(ticket.id),
          ),
          trailing: Icon(
            Icons.circle,
            size: 15,
            color: ticket.status == "DONE" ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: circularProgressIndicator)
        : _tickets.length == 0
            ? Center(
                child: Text(getTranslate(context, "NO_RESULT_FOUND")),
              )
            : ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: _tickets.length,
                itemBuilder: (context, index) {
                  return ticketCardOld(_tickets[index]);
                },
              );
  }
}
