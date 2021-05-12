import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/service.dart';
import 'package:issaf/services/serviceService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HandleService extends StatefulWidget {
  final int serviceId;
  final void Function(int) callback;
  HandleService(this.serviceId, this.callback);
  @override
  _HandleServiceState createState() => _HandleServiceState();
}

class _HandleServiceState extends State<HandleService> {
  bool _isLoading = true;
  bool _isCounterLoading = false;
  String _error;
  int _counter = 0;
  Service _service;
  Timer _timer;
  int seconds = 0, minutes = 0, hours = 0;
  bool _isStarted = false;

  @override
  void initState() {
    super.initState();
    initializeServiceData();
    _startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void resetTimer() {
    setState(() {
      seconds = minutes = hours = 0;
    });
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(() {
        seconds = seconds + 1;
        if (seconds > 59) {
          minutes += 1;
          seconds = 0;
          if (minutes > 59) {
            hours += 1;
            minutes = 0;
          }
        }
      }),
    );
  }

  void initializeServiceData() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      var response = await ServiceService()
          .getServiceById(prefs.getString('token'), widget.serviceId);
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
      int _dur = 0;
      if (status == "DONE") {
        if (seconds > 30) _dur++;
        _dur += minutes;
        _dur += hours * 60;
      }
      final response = await ServiceService().incrementCounter(
          prefs.getString('token'), _service.id, status, _dur);
      assert(response.statusCode == 200);
      _counter = json.decode(response.body)["counter"];
      _isStarted = false;
      setState(() {
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

  // void _decrementCounter(int id) async {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: new Text(getTranslate(context, "DECREMENT_COUNTER")),
  //         content:
  //             new Text(getTranslate(context, "DECREMENT_COUNTER_CONFIRMATION")),
  //         actions: <Widget>[
  //           // ignore: deprecated_member_use
  //           new FlatButton(
  //             child: new Text(getTranslate(context, "NO")),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           // ignore: deprecated_member_use
  //           new FlatButton(
  //             child: new Text(getTranslate(context, "YES")),
  //             onPressed: () async {
  //               Navigator.of(context).pop();
  //               try {
  //                 setState(() {
  //                   _isCounterLoading = true;
  //                 });
  //                 var prefs = await SharedPreferences.getInstance();
  //                 final response = await ServiceService().updateCounter(
  //                     prefs.getString('token'),
  //                     id,
  //                     _counter == 1 ? 1 : _counter - 1);
  //                 assert(response.statusCode == 200);
  //                 setState(() {
  //                   _counter--;
  //                   _isCounterLoading = false;
  //                 });
  //               } catch (error) {
  //                 final snackBar = SnackBar(
  //                   content: Text(getTranslate(context, "ERROR_SERVER")),
  //                 );
  //                 ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //                 setState(() {
  //                   _isCounterLoading = false;
  //                 });
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _getOpenDays(Service service) {
    // ignore: deprecated_member_use
    List<Widget> list = new List<Widget>();
    list.add(Icon(Icons.calendar_today));
    list.add(Text(" : "));
    for (var i = 0; i < service.openDays.length; i++) {
      list.add(
          new Text(getTranslate(context, service.openDays[i].toUpperCase())));
      list.add(Text(", "));
    }
    return new Row(children: list);
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
                  Text(
                    getTranslate(context, "CLIENT_NUMBER") +
                        " " +
                        service.counter.toString(),
                    style: TextStyle(
                        backgroundColor: Colors.orange,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined),
                      Expanded(
                          child: Text(
                              " : " + service.workStartTime.substring(0, 5)))
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.timer_off),
                      Expanded(
                          child:
                              Text(" : " + service.workEndTime.substring(0, 5)))
                    ],
                  ),
                  _getOpenDays(service)
                ],
              ));
        });
  }

  Widget _getTimer() {
    String _hours = hours < 10 ? "0" + hours.toString() : hours.toString();
    String _minutes =
        minutes < 10 ? "0" + minutes.toString() : minutes.toString();
    String _seconds =
        seconds < 10 ? "0" + seconds.toString() : seconds.toString();
    return Text(
      _hours + ":" + _minutes + ":" + _seconds,
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.navigate_before),
          onPressed: () => widget.callback(0),
        ),
        actions: [
          PopupMenuButton(
            enabled: _isCounterLoading || _isLoading || _service == null
                ? false
                : true,
            onSelected: (value) {
              if (value == "RESET_COUNTER")
                _resetCounter(_service.id);
              // else if (value == "DECREMENT_COUNTER")
              //   _decrementCounter(_service.id);
              else if (value == "INFO_SERVICE") _showServiceInfo(_service);
            },
            itemBuilder: (BuildContext context) {
              return {"RESET_COUNTER", "INFO_SERVICE"}.map((String choice) {
                return PopupMenuItem(
                  value: choice,
                  child: Text(getTranslate(context, choice)),
                );
              }).toList();
            },
          ),
        ],
        title: Text(_isLoading || _service == null ? "..." : _service.title),
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
                      Text(
                        _counter.toString(),
                        style: TextStyle(
                            fontSize: 80, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      _isStarted
                          ? Row(
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
                                    color: Colors.red,
                                    label:
                                        Text(getTranslate(context, "UNDONE")),
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
                                    color: Colors.green,
                                    label: Text(getTranslate(context, "DONE")),
                                    onPressed: _isCounterLoading
                                        ? null
                                        : () => _incrementCounter("DONE"),
                                  ),
                                ),
                              ],
                            )
                          // ignore: deprecated_member_use
                          : RaisedButton.icon(
                              elevation: 5.0,
                              icon: Icon(Icons.play_arrow),
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(30.0)),
                              color: Colors.grey,
                              label: Text("Commencer"),
                              onPressed: () => {
                                resetTimer(),
                                setState(() {
                                  _isStarted = true;
                                })
                              },
                            ),
                      _isStarted ? _getTimer() : SizedBox.shrink(),
                    ],
                  ),
      ),
    );
  }
}
