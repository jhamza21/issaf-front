import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/request.dart';
import 'package:issaf/services/requestService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notifications extends StatefulWidget {
  final void Function(int) callback;
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

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var prefs = await SharedPreferences.getInstance();
      final response = await RequestService()
          .fetchReceivedRequests(prefs.getString('token'));
      assert(response.statusCode == 200);
      final jsonData = json.decode(response.body);
      _requests = Request.listFromJson(jsonData);
      _requests.removeWhere((element) => element.status != null);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _refuseRequest(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(getTranslate(context, "REFUSE")),
          content: new Text(getTranslate(context, "REFUSE_CONFIRMATION")),
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
                      .refuseRequest(prefs.getString('token'), id);
                  assert(res.statusCode == 200);
                  final snackBar = SnackBar(
                    content:
                        Text(getTranslate(context, "SUCCESS_REFUSE_REQUEST")),
                  );
                  Navigator.of(context).pop();
                  await _fetchRequests();
                  widget.callback(_requests.length);
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } catch (e) {
                  Navigator.of(context).pop();
                  final snackBar = SnackBar(
                    content: Text(getTranslate(context, "ERROR_SERVER")),
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

  void _acceptRequest(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(getTranslate(context, "ACCEPT")),
          content: new Text(getTranslate(context, "ACCEPT_CONFIRMATION")),
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
                      .acceptRequest(prefs.getString('token'), id);
                  assert(res.statusCode == 200);
                  final snackBar = SnackBar(
                    content:
                        Text(getTranslate(context, "SUCCESS_ACCEPT_REQUEST")),
                  );
                  Navigator.of(context).pop();
                  await _fetchRequests();
                  widget.callback(_requests.length);
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } catch (e) {
                  Navigator.of(context).pop();
                  final snackBar = SnackBar(
                    content: Text(getTranslate(context, "ERROR_SERVER")),
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
    return Card(
      color: Colors.orange[50],
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(
              request.dateTime.substring(0, 11) +
                  getTranslate(context, "A") +
                  request.dateTime.substring(11, 16),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              request.sender.name +
                  getTranslate(context, "INVITED_YOU") +
                  request.service.title,
              style: TextStyle(fontSize: 13),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.remove_circle,
                    color: Colors.red[600],
                  ),
                  onPressed: () {
                    _refuseRequest(request.id);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.check_circle,
                    color: Colors.green[800],
                  ),
                  onPressed: () {
                    _acceptRequest(request.id);
                  },
                ),
              ],
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(getTranslate(context, "REQUESTS")),
          actions: [
            IconButton(
                onPressed: () => _fetchRequests(), icon: Icon(Icons.refresh))
          ],
          elevation: 0,
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
