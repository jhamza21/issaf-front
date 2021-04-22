import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/request.dart';
import 'package:issaf/models/service.dart';
import 'package:issaf/models/user.dart';
import 'package:issaf/services/requestService.dart';
import 'package:issaf/services/serviceService.dart';
import 'package:issaf/services/userService.dart';
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
      final response = await RequestService()
          .fetchReceivedRequests(prefs.getString('token'));
      assert(response.statusCode == 200);
      final jsonData = json.decode(response.body);
      _requests = Request.listFromJson(jsonData);
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> getRequestData(Request request) async {
    try {
      var prefs = await SharedPreferences.getInstance();
      var res = await UserService()
          .getUserById(prefs.getString('token'), request.senderId);
      assert(res.statusCode == 200);
      User sender = User.fromJson(json.decode(res.body));

      res = await ServiceService()
          .getServiceById(prefs.getString('token'), request.serviceId);
      assert(res.statusCode == 200);
      Service service = Service.fromJson(json.decode(res.body));
      return {"sender": sender, "service": service};
    } catch (e) {
      return null;
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
                  _fetchRequests();
                  widget.callback();
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
                  _fetchRequests();
                  widget.callback();
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

  Card requestCard(int id, String sender, String serviceName, String date) {
    return Card(
      color: Colors.orange[50],
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(
              date,
            ),
            subtitle: Text(
                sender + getTranslate(context, "INVITED_YOU") + serviceName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.remove_circle,
                    color: Colors.red[600],
                  ),
                  onPressed: () {
                    _refuseRequest(id);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.check_circle,
                    color: Colors.green[800],
                  ),
                  onPressed: () {
                    _acceptRequest(id);
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
                      return FutureBuilder(
                        future: getRequestData(_requests[index]),
                        builder: (context, snapshot) {
                          return snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.data != null
                              ? requestCard(
                                  _requests[index].id,
                                  snapshot.data["sender"].name,
                                  snapshot.data["service"].title,
                                  _requests[index].dateTime)
                              : Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child:
                                      Center(child: circularProgressIndicator),
                                );
                        },
                      );
                    },
                  ));
  }
}
