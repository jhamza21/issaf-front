import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/ticket.dart';
import 'package:issaf/services/ticketService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketsOld extends StatefulWidget {
  final int serviceId;
  TicketsOld(this.serviceId);
  @override
  _TicketsOldState createState() => _TicketsOldState();
}

class _TicketsOldState extends State<TicketsOld> {
  bool _isLoading = true;
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
      final response = await TicketService()
          .fetchOperatorTickets(prefs.getString('token'), widget.serviceId);
      assert(response.statusCode == 200);
      final jsonData = json.decode(response.body);
      _tickets = Ticket.listFromJson(jsonData);
      _tickets.removeWhere((element) => element.status == "IN_PROGRESS");
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
