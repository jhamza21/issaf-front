import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/service.dart';
import 'package:issaf/services/serviceService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HandleService extends StatefulWidget {
  @override
  _HandleServiceState createState() => _HandleServiceState();
}

class _HandleServiceState extends State<HandleService> {
  bool _isLoading = true;
  bool _isCounterLoading = false;
  String _error;
  Service _service;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    initializeServiceData();
  }

  void initializeServiceData() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      var response =
          await ServiceService().getServiceByAdmin(prefs.getString('token'));
      if (response.statusCode == 404) {
        _error = getTranslate(context, "REGISTER_TO_SERVER");
        setState(() {
          _isLoading = false;
        });
        return;
      }
      assert(response.statusCode == 200);
      var jsonData = json.decode(response.body);
      _service = Service.fromJson(jsonData);
      _counter = _service.counter;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _error = getTranslate(context, "ERROR_SERVER");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _incrementCounter(String status) async {
    try {
      setState(() {
        _isCounterLoading = true;
      });
      var prefs = await SharedPreferences.getInstance();
      final response = await ServiceService()
          .incrementCounter(prefs.getString('token'), _service.id, status);
      assert(response.statusCode == 200);
      setState(() {
        _counter++;
        _isCounterLoading = false;
      });
    } catch (error) {
      final snackBar = SnackBar(
        content: Text(getTranslate(context, "ERROR_SERVER")),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        _isCounterLoading = false;
      });
    }
  }

  void _resetCounter(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(getTranslate(context, "RESET_COUNTER")),
          content:
              new Text(getTranslate(context, "RESET_COUNTER_CONFIRMATION")),
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
                    _isCounterLoading = true;
                  });
                  var prefs = await SharedPreferences.getInstance();
                  final response = await ServiceService()
                      .updateCounter(prefs.getString('token'), id, 1);
                  assert(response.statusCode == 200);
                  setState(() {
                    _counter = 1;
                    _isCounterLoading = false;
                  });
                } catch (error) {
                  final snackBar = SnackBar(
                    content: Text(getTranslate(context, "ERROR_SERVER")),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  setState(() {
                    _isCounterLoading = false;
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _decrementCounter(int id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(getTranslate(context, "DECREMENT_COUNTER")),
          content:
              new Text(getTranslate(context, "DECREMENT_COUNTER_CONFIRMATION")),
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
                    _isCounterLoading = true;
                  });
                  var prefs = await SharedPreferences.getInstance();
                  final response = await ServiceService().updateCounter(
                      prefs.getString('token'),
                      id,
                      _counter == 1 ? 1 : _counter - 1);
                  assert(response.statusCode == 200);
                  setState(() {
                    _counter--;
                    _isCounterLoading = false;
                  });
                } catch (error) {
                  final snackBar = SnackBar(
                    content: Text(getTranslate(context, "ERROR_SERVER")),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  setState(() {
                    _isCounterLoading = false;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.repeat),
          onPressed: _isCounterLoading || _isLoading
              ? null
              : () => _resetCounter(_service.id),
        ),
        title: Text(getTranslate(context, "HOME")),
      ),
      body: Center(
        child: _isLoading
            ? circularProgressIndicator
            : _error != null
                ? Text(_error)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        getTranslate(context, "CLIENT_NUMBER"),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      _isCounterLoading
                          ? circularProgressIndicator
                          : Text(
                              _counter.toString(),
                              style: TextStyle(
                                  fontSize: 80, fontWeight: FontWeight.bold),
                            ),
                      SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ButtonTheme(
                            minWidth: 150,
                            // ignore: deprecated_member_use
                            child: RaisedButton.icon(
                              elevation: 5.0,
                              icon: Icon(Icons.dangerous),
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(30.0)),
                              color: Colors.red[900],
                              label: Text(getTranslate(context, "UNDONE")),
                              onPressed: _isCounterLoading
                                  ? null
                                  : () => _incrementCounter("UNDONE"),
                            ),
                          ),
                          ButtonTheme(
                            minWidth: 150,
                            // ignore: deprecated_member_use
                            child: RaisedButton.icon(
                              elevation: 5.0,
                              icon: Icon(Icons.done),
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(30.0)),
                              color: Colors.green[900],
                              label: Text(getTranslate(context, "DONE")),
                              onPressed: _isCounterLoading
                                  ? null
                                  : () => _incrementCounter("DONE"),
                            ),
                          ),
                        ],
                      ),
                      ButtonTheme(
                        minWidth: 150,
                        // ignore: deprecated_member_use
                        child: RaisedButton.icon(
                          elevation: 5.0,
                          icon: Icon(Icons.navigate_before),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          color: Colors.grey,
                          label: Text(getTranslate(context, "DECREMENT")),
                          onPressed: _isCounterLoading
                              ? null
                              : () => _decrementCounter(_service.id),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
