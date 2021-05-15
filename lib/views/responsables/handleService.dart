import 'dart:async';
import 'dart:convert';

import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/service.dart';
import 'package:issaf/models/ticket.dart';
import 'package:issaf/services/serviceService.dart';
import 'package:issaf/services/ticketService.dart';
import 'package:issaf/views/responsables/tickets.dart';
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
  bool _isHandlingTicket = false;
  String _error;
  Service _service;
  Time _selectedTime;
  List<Time> _times = [];
  Timer _timer;
  int seconds = 0, minutes = 0, hours = 0, _currentIndex = 0;
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

  void initializeServiceData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var prefs = await SharedPreferences.getInstance();
      var response;
      if (widget.serviceId != null)
        response = await ServiceService()
            .getServiceById(prefs.getString('token'), widget.serviceId);
      else
        response =
            await ServiceService().getServiceByRespo(prefs.getString('token'));
      if (response.statusCode == 404) {
        _error = getTranslate(context, "REGISTER_TO_SERVER");
        setState(() {
          _isLoading = false;
        });
        return;
      }
      assert(response.statusCode == 200);
      _times = [];
      _service = Service.fromJson(json.decode(response.body));
      String _todayDate = new DateFormat("yyyy-MM-dd").format(DateTime.now());
      var res = await TicketService().fetchAvailableTicketsByDate(
          prefs.getString('token'), _todayDate, _service.id);
      assert(res.statusCode == 200);
      var jsonData = json.decode(res.body);
      if (jsonData.length != 0)
        jsonData.entries
            .forEach((entry) => _times.add(Time(entry.key, entry.value)));
      for (int i = 0; i < _times.length; i++) {
        Ticket _ticket = _service.tickets.firstWhere(
            (element) =>
                element.status == "DONE" &&
                element.time.substring(0, 5) == _times[i].value,
            orElse: () => null);
        _times[i].isDone =
            _service.counter > i + 1 || _ticket != null ? true : false;
      }
      _selectedTime = _times.length >= _service.counter - 1
          ? _times[_service.counter - 1]
          : null;
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

  void changePage(int i) {
    setState(() {
      _currentIndex = i;
    });
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

  void _resetCounter(int id) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: new Text(getTranslate(context, "RESET_COUNTER")),
          content:
              new Text(getTranslate(context, "RESET_COUNTER_CONFIRMATION")),
          actions: <Widget>[
            // ignore: deprecated_member_use
            new FlatButton(
              child: new Text(getTranslate(context, "NO")),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            // ignore: deprecated_member_use
            new FlatButton(
              child: new Text(getTranslate(context, "YES")),
              onPressed: () async {
                try {
                  Navigator.of(dialogContext).pop();
                  setState(() {
                    _isHandlingTicket = true;
                  });
                  var prefs = await SharedPreferences.getInstance();
                  final response = await ServiceService()
                      .updateCounter(prefs.getString('token'), id, 1);
                  assert(response.statusCode == 200);
                  initializeServiceData();
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

  void _validateTicket(String status) async {
    try {
      setState(() {
        _isHandlingTicket = true;
      });
      var prefs = await SharedPreferences.getInstance();
      int _dur = 0;
      if (status == "DONE") {
        if (seconds > 30) _dur++;
        _dur += minutes;
        _dur += hours * 60;
      }

      final response = await TicketService()
          .validateTicket(prefs.getString('token'), _service.id, status, _dur);
      assert(response.statusCode == 200);
      var jsonData = json.decode(response.body);
      _service = Service.fromJson(jsonData);
      _times[_times.indexOf(_selectedTime)].isDone = true;
      _selectedTime = _times.length >= _service.counter - 1
          ? _times[_service.counter - 1]
          : null;
      _isStarted = false;
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
  //               try {
  //                 if (_counter == 1) return;
  //                 Navigator.of(context).pop();
  //                 setState(() {
  //                   _isHandlingTicket = true;
  //                 });
  //                 var prefs = await SharedPreferences.getInstance();
  //                 final response = await ServiceService().updateCounter(
  //                     prefs.getString('token'), id, _counter - 1);
  //                 assert(response.statusCode == 200);
  //                 resetTimer();
  //                 setState(() {
  //                   _counter--;
  //                   _isHandlingTicket = false;
  //                 });
  //               } catch (error) {
  //                 final snackBar = SnackBar(
  //                   content: Text(getTranslate(context, "ERROR_SERVER")),
  //                 );
  //                 ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //                 setState(() {
  //                   _isHandlingTicket = false;
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
      list.add(new Text(service.hoolidays[i]));
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
      list.add(new Text(service.breakTimes[i]));
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
                  Text(
                    getTranslate(context, "SERVICE_INFO_COUNTER") +
                        service.counter.toString(),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
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
    return _currentIndex == 1
        ? Tickets(changePage, _service)
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              elevation: 0,
              leading: widget.callback != null
                  ? IconButton(
                      icon: Icon(Icons.navigate_before),
                      onPressed: () => widget.callback(0),
                    )
                  : null,
              actions: [
                PopupMenuButton(
                  enabled: _isHandlingTicket || _isLoading || _service == null
                      ? false
                      : true,
                  onSelected: (value) {
                    if (value == "HANDLE_TICKETS") changePage(1);
                    if (value == "RESET_COUNTER") _resetCounter(_service.id);
                    if (value == "INFO_SERVICE") _showServiceInfo(_service);
                  },
                  itemBuilder: (BuildContext context) {
                    return {"HANDLE_TICKETS", "RESET_COUNTER", "INFO_SERVICE"}
                        .map((String choice) {
                      return PopupMenuItem(
                        value: choice,
                        child: Row(
                          children: [
                            Icon(
                                choice == "HANDLE_TICKETS"
                                    ? Icons.bookmark
                                    : choice == "RESET_COUNTER"
                                        ? Icons.repeat
                                        : Icons.info,
                                color: Colors.grey),
                            Text("  " + getTranslate(context, choice)),
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),
              ],
              title:
                  Text(_isLoading || _service == null ? "..." : _service.title),
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
                              getTranslate(context, "TICKET_NUMBER"),
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(30)),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    50.0, 10.0, 50.0, 10.0),
                                child: DropdownButton<Time>(
                                  underline: SizedBox(),
                                  value: _selectedTime,
                                  elevation: 5,
                                  style: TextStyle(color: Colors.black),
                                  items: _times.map<DropdownMenuItem<Time>>(
                                      (Time value) {
                                    return DropdownMenuItem<Time>(
                                      value: value,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            (_times.indexOf(value) + 1)
                                                    .toString() +
                                                " - ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                          Text(" (~" + value.value + ")"),
                                          Icon(Icons.circle,
                                              size: 15,
                                              color: value.isDone
                                                  ? Colors.green
                                                  : Colors.grey)
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  hint: Text(
                                    getTranslate(context, "NO_TICKETS"),
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  onChanged: _isStarted
                                      ? null
                                      : (Time value) {
                                          if (value.isDone) {
                                            final snackBar = SnackBar(
                                              content: Text(getTranslate(
                                                  context,
                                                  "TICKET_ALREADY_DONE")),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                          } else
                                            setState(() {
                                              _selectedTime = value;
                                            });
                                        },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            _isStarted
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ButtonTheme(
                                        minWidth: 150,
                                        // ignore: deprecated_member_use
                                        child: RaisedButton.icon(
                                          elevation: 5.0,
                                          icon: Icon(Icons.dangerous),
                                          shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      30.0)),
                                          color: Colors.red,
                                          label: Text(
                                              getTranslate(context, "UNDONE")),
                                          onPressed: _isHandlingTicket
                                              ? null
                                              : () => _validateTicket("UNDONE"),
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
                                                  new BorderRadius.circular(
                                                      30.0)),
                                          color: Colors.green,
                                          label: Text(
                                              getTranslate(context, "DONE")),
                                          onPressed: _isHandlingTicket
                                              ? null
                                              : () => _validateTicket("DONE"),
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
                                    label: Text(getTranslate(context, "BEGIN")),
                                    onPressed: _isHandlingTicket ||
                                            _selectedTime == null
                                        ? null
                                        : () => {
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

class Time {
  String value;
  bool isDone;

  Time(this.value, this.isDone);
}
