import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/request.dart';
import 'package:issaf/models/service.dart';
import 'package:issaf/services/requestService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<Request> _requests = [];
  bool _isLoading = true, _isHandlingRequest = false;

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
      _requests = _requests.reversed.toList();
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
                  Navigator.of(context).pop();
                  setState(() {
                    _isHandlingRequest = true;
                  });
                  var prefs = await SharedPreferences.getInstance();
                  var res = await RequestService()
                      .refuseRequest(prefs.getString('token'), id);
                  assert(res.statusCode == 200);
                  _requests.removeWhere((element) => element.id == id);
                  final snackBar = SnackBar(
                    content:
                        Text(getTranslate(context, "SUCCESS_REFUSE_REQUEST")),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  setState(() {
                    _isHandlingRequest = false;
                  });
                } catch (e) {
                  setState(() {
                    _isHandlingRequest = false;
                  });
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
                  Navigator.of(context).pop();
                  setState(() {
                    _isHandlingRequest = true;
                  });
                  var prefs = await SharedPreferences.getInstance();
                  var res = await RequestService()
                      .acceptRequest(prefs.getString('token'), id);
                  assert(res.statusCode == 200);
                  _requests.removeWhere((element) => element.id == id);
                  final snackBar = SnackBar(
                    content:
                        Text(getTranslate(context, "SUCCESS_ACCEPT_REQUEST")),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  setState(() {
                    _isHandlingRequest = false;
                  });
                } catch (e) {
                  setState(() {
                    _isHandlingRequest = false;
                  });
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

  Widget _getOpenDays(Service service) {
    // ignore: deprecated_member_use
    List<Widget> list = new List<Widget>();
    list.add(Text(
      getTranslate(context, "WORK_DAYS"),
      style: TextStyle(fontWeight: FontWeight.bold),
    ));
    for (var i = 0; i < service.openDays.length; i++) {
      list.add(
          new Text(getTranslate(context, service.openDays[i].toUpperCase())));
      list.add(Text(", "));
    }
    return new Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          children: list,
        ));
  }

  Widget _getHoolidays(Service service) {
    // ignore: deprecated_member_use
    List<Widget> list = new List<Widget>();
    list.add(Text(
      getTranslate(context, "HOOLI_DAYS"),
      style: TextStyle(fontWeight: FontWeight.bold),
    ));
    for (var i = 0; i < service.hoolidays.length; i++) {
      list.add(new Text(getTranslate(context, service.hoolidays[i])));
      list.add(Text("/"));
    }
    if (service.hoolidays.length == 0)
      list.add(Text(getTranslate(context, "NO_HOOLIDAYS")));

    return new Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          children: list,
        ));
  }

  Widget _getBreakTimes(Service service) {
    // ignore: deprecated_member_use
    List<Widget> list = new List<Widget>();
    list.add(Text(
      getTranslate(context, "BREAKTIMES"),
      style: TextStyle(fontWeight: FontWeight.bold),
    ));
    for (var i = 0; i < service.breakTimes.length; i++) {
      list.add(new Text(getTranslate(context, service.breakTimes[i])));
      list.add(Text("/"));
    }
    if (service.breakTimes.length == 0)
      list.add(Text(getTranslate(context, "NO_BREAKTIMES")));

    return new Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          children: list,
        ));
  }

  void _showServiceInfo(Service service) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return customDialog(
              service.title,
              service.description,
              service.image != null ? "serviceImg/" + service.image : null,
              Column(
                children: [
                  Divider(),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      children: [
                        Text(
                          getTranslate(context, "WORK_TIME_INFO"),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(service.workStartTime.substring(0, 5) +
                            getTranslate(context, "A") +
                            service.workEndTime.substring(0, 5))
                      ],
                    ),
                  ),
                  _getOpenDays(service),
                  Align(
                      alignment: Alignment.topLeft,
                      child: Wrap(
                        children: [
                          Text(
                            getTranslate(context, "AVG_TIME_INFO"),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(service.timePerClient.toString())
                        ],
                      )),
                  _getBreakTimes(service),
                  _getHoolidays(service),
                ],
              ));
        });
  }

  Card requestCard(Request request) {
    return Card(
      color: Colors.orange[50],
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: IconButton(
              icon: Icon(Icons.info),
              onPressed: () => _showServiceInfo(request.service),
            ),
            title: Text(
              request.dateTime.substring(0, 11) +
                  getTranslate(context, "A") +
                  request.dateTime.substring(11, 16),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              children: [
                Text(
                  request.sender.name +
                      " (" +
                      request.sender.username +
                      ") " +
                      getTranslate(context, "INVITED_YOU") +
                      request.service.title,
                  style: TextStyle(fontSize: 13),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _isHandlingRequest
                          ? null
                          : () => _acceptRequest(request.id),
                      label: Text(
                        getTranslate(context, "ACCEPT"),
                        style: TextStyle(color: Colors.black),
                      ),
                      icon: Icon(
                        Icons.check_circle,
                        size: 17,
                        color: Colors.green[800],
                      ),
                    ),
                    TextButton.icon(
                        icon: Icon(
                          Icons.remove_circle,
                          size: 17,
                          color: Colors.red[600],
                        ),
                        onPressed: _isHandlingRequest
                            ? null
                            : () => _refuseRequest(request.id),
                        label: Text(
                          getTranslate(context, "REFUSE"),
                          style: TextStyle(color: Colors.black),
                        ))
                  ],
                )
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
                onPressed: _isLoading ? null : () => _fetchRequests(),
                icon: Icon(Icons.refresh))
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
