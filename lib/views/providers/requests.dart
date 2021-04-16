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

class Requests extends StatefulWidget {
  final bool isReceivedRequests;
  Requests(this.isReceivedRequests);
  @override
  _RequestsState createState() => _RequestsState();
}

@override
class _RequestsState extends State<Requests> {
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
      final response = widget.isReceivedRequests
          ? await RequestService()
              .fetchReceivedRequests(prefs.getString('token'))
          : await RequestService()
              .fetchSendedRequests(prefs.getString('token'));
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
      if (widget.isReceivedRequests) {
        var res = await UserService()
            .getUserById(prefs.getString('token'), request.senderId);
        assert(res.statusCode == 200);
        sender = User.fromJson(json.decode(res.body));
      } else {
        var res = await UserService()
            .getUserById(prefs.getString('token'), request.receiverId);
        assert(res.statusCode == 200);
        receiver = User.fromJson(json.decode(res.body));
      }
      var res = await ServiceService()
          .getServiceById(prefs.getString('token'), request.serviceId);
      assert(res.statusCode == 200);
      Service service = Service.fromJson(json.decode(res.body));
      return {"sender": sender, "service": service, "receiver": receiver};
    } catch (e) {
      return null;
    }
  }

  Card requestCard(
      int id, String sender, String serviceName, String receiver, String date) {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: widget.isReceivedRequests
            ? ListTile(
                title: Text(
                  date,
                  style: TextStyle(fontSize: 24.0),
                ),
                subtitle: Text(sender +
                    getTranslate(context, "WAS_INVITED") +
                    serviceName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle,
                        color: Colors.red[600],
                      ),
                      onPressed: () async {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.check_circle,
                        color: Colors.green[800],
                      ),
                      onPressed: () async {},
                    ),
                  ],
                ),
              )
            : ListTile(
                title: Text(
                  date,
                ),
                subtitle: Text(receiver +
                    getTranslate(context, "IS_INVITED_FOR") +
                    serviceName),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: new Text(getTranslate(context, "DELETE")),
                          content: new Text(getTranslate(
                                  context, "DELETE_REQUEST_CONFIRMATION") +
                              receiver +
                              " ?"),
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
                                  var prefs =
                                      await SharedPreferences.getInstance();
                                  var res = await RequestService()
                                      .deleteRequest(
                                          prefs.getString('token'), id);
                                  assert(res.statusCode == 204);
                                  final snackBar = SnackBar(
                                    content: Text(getTranslate(
                                        context, "SUCCESS_DELETE")),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                } catch (e) {
                                  final snackBar = SnackBar(
                                    content: Text(
                                        getTranslate(context, "FAIL_DELETE")),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                  widget.isReceivedRequests
                                      ? snapshot.data["sender"].name
                                      : null,
                                  snapshot.data["service"].title,
                                  !widget.isReceivedRequests
                                      ? snapshot.data["receiver"].name
                                      : null,
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
