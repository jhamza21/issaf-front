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
      final response =
          await RequestService().fetchSendedRequests(prefs.getString('token'));
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
      User sender, receiver;
      var prefs = await SharedPreferences.getInstance();

      var res = await UserService()
          .getUserById(prefs.getString('token'), request.receiverId);
      assert(res.statusCode == 200);
      receiver = User.fromJson(json.decode(res.body));

      res = await ServiceService()
          .getServiceById(prefs.getString('token'), request.serviceId);
      assert(res.statusCode == 200);
      Service service = Service.fromJson(json.decode(res.body));
      return {"sender": sender, "service": service, "receiver": receiver};
    } catch (e) {
      return null;
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

  Card requestCard(int id, String sender, String serviceName, String receiver,
      String date, String status) {
    String _subtitle, _confirmation;
    _confirmation = getTranslate(context, "DELETE_REQUEST_CONFIRMATION");
    _confirmation += receiver;
    _confirmation += "?";
    _subtitle = receiver;
    _subtitle += getTranslate(context, "IS_INVITED_FOR");
    _subtitle += serviceName;

    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(
            date,
          ),
          subtitle: Text(_subtitle),
          trailing: IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () {
              _deleteNotification(id, _confirmation);
            },
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
                      return FutureBuilder(
                        future: getRequestData(_requests[index]),
                        builder: (context, snapshot) {
                          return snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.data != null
                              ? requestCard(
                                  _requests[index].id,
                                  snapshot.data["sender"] != null
                                      ? snapshot.data["sender"].name
                                      : null,
                                  snapshot.data["service"].title,
                                  snapshot.data["receiver"] != null
                                      ? snapshot.data["receiver"].name
                                      : null,
                                  _requests[index].dateTime,
                                  _requests[index].status)
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
