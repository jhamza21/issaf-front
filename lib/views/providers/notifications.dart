import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/request.dart';
import 'package:issaf/services/requestService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notifications extends StatefulWidget {
  final void Function() callback;
  Notifications(this.callback);
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<Request> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  void _fetchRequests() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      final response =
          await RequestService().fetchSendedRequests(prefs.getString('token'));
      assert(response.statusCode == 200);
      final jsonData = json.decode(response.body);
      _requests = Request.listFromJson(jsonData);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteNotification(int id, String confirmationMsg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(getTranslate(context, "DELETE") + "?"),
          content: new Text(confirmationMsg),
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
                  var prefs = await SharedPreferences.getInstance();
                  var res = await RequestService()
                      .deleteRequest(prefs.getString('token'), id);
                  assert(res.statusCode == 204);
                  final snackBar = SnackBar(
                    content: Text(getTranslate(context, "SUCCESS_DELETE")),
                  );
                  widget.callback();
                  _fetchRequests();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } catch (e) {
                  Navigator.of(context).pop();
                  final snackBar = SnackBar(
                    content: Text(getTranslate(context, "FAIL_DELETE")),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Card requestCard(Request request) {
    String _subtitle, _confirmation;
    _confirmation = getTranslate(context, "DELETE_REQUEST_CONFIRMATION");
    _confirmation += request.receiver.name;
    _confirmation += "?";
    _subtitle = request.receiver.name;
    _subtitle += getTranslate(context, "IS_INVITED_FOR");
    _subtitle += request.service.title;

    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(
            request.dateTime,
          ),
          subtitle: Text(_subtitle),
          leading: IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () {
              _deleteNotification(request.id, _confirmation);
            },
          ),
          trailing: Icon(
            Icons.circle,
            color: request.status == null
                ? Colors.grey
                : request.status == "ACCEPTED"
                    ? Colors.green
                    : Colors.red,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(getTranslate(context, "NOTIFICATIONS")),
        ),
        body: _isLoading
            ? Center(child: circularProgressIndicator)
            : _requests.length == 0
                ? Center(
                    child: Text(getTranslate(context, "NO_RESULT_FOUND")),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      return requestCard(_requests[index]);
                    },
                  ));
  }
}
