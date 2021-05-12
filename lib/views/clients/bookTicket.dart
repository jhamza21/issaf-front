import 'dart:convert';

import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/service.dart';
import 'package:issaf/services/ticketService.dart';

class BookTicket extends StatefulWidget {
  final Service service;
  final void Function(int) callback;

  final void Function() fetchTickets;
  BookTicket(this.service, this.callback, this.fetchTickets);
  @override
  _BookTicketState createState() => _BookTicketState();
}

class _BookTicketState extends State<BookTicket> {
  String _selectedDate = new DateFormat("yyyy-MM-dd").format(DateTime.now()),
      _error;
  Time _selectedTime;
  bool _isLoading = false, _isFetchingTimes;
  List<int> _notifications = [];
  List<Time> _times = [];
  List<Time> _timesOnlyAvailable = [];
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAvailableTimes();
    _controller.text = "1"; // Setting the initial value for the field.
  }

  void _fetchAvailableTimes() async {
    try {
      setState(() {
        _isFetchingTimes = true;
        _error = null;
      });
      var prefs = await SharedPreferences.getInstance();
      var res = await TicketService().fetchAvailableTicketsByDat(
          prefs.getString('token'),
          _selectedDate,
          widget.service.id.toString());
      assert(res.statusCode == 200);
      json
          .decode(res.body)
          .entries
          .forEach((entry) => _times.add(Time(entry.key, entry.value)));
      //get first available time
      //get first available time
      for (var i = 0; i < _times.length; i++) {
        if (_times[i].isAvailable == "T") {
          _selectedTime = _times[i];
          break;
        }
      }
      for (var i = 0; i < _times.length; i++) {
        if (_times[i].isAvailable == "N" || _times[i].isAvailable == "T") {
          _timesOnlyAvailable.add(_times[i]);
        }
      }

      setState(() {
        _isFetchingTimes = false;
      });
    } catch (e) {
      setState(() {
        _isFetchingTimes = false;
      });
      _error = getTranslate(context, "ERROR_SERVER");
    }
  }

//book ticket
  void _getTicket() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      var prefs = await SharedPreferences.getInstance();
      var res;
      if (widget.fetchTickets != null)
        res = await TicketService().reschudleTicket(
            prefs.getString('token'),
            _selectedDate,
            _selectedTime.value,
            _timesOnlyAvailable.indexOf(_selectedTime) + 1,
            widget.service.id,
            _notifications);
      else
        res = await TicketService().addTicket(
            prefs.getString('token'),
            _selectedDate,
            _selectedTime.value,
            _timesOnlyAvailable.indexOf(_selectedTime) + 1,
            widget.service.id,
            _notifications);
      if (res.statusCode == 201 || res.statusCode == 200) {
        final snackBar = SnackBar(
          content: Text(getTranslate(context, "SUCCESS_ADD")),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        if (widget.fetchTickets != null) widget.fetchTickets();
        widget.callback(0);
      } else {
        setState(() {
          _isLoading = false;
          _error = getTranslate(context, json.decode(res.body)["error"]);
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = getTranslate(context, "ERROR_SERVER");
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (d != null)
      setState(() {
        _selectedDate = new DateFormat("yyyy-MM-dd").format(d);
        _fetchAvailableTimes();
      });
  }

  Widget _showDatePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.calendar_today),
        SizedBox(
          width: 20,
        ),
        InkWell(
          child: Text(_selectedDate,
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF000000))),
          onTap: () {
            _selectDate(context);
          },
        ),
      ],
    );
  }

  Widget _showTimeInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.access_time),
        SizedBox(
          width: 20,
        ),
        _isFetchingTimes
            ? circularProgressIndicator
            : DropdownButton(
                dropdownColor: Colors.orange[50],
                value: _selectedTime,
                onChanged: (Time value) {
                  if (value.isAvailable != "T") {
                    final snackBar = SnackBar(
                      content:
                          Text(getTranslate(context, "UNAVAILABLE_TICKET")),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else
                    setState(() {
                      _selectedTime = value;
                    });
                },
                underline: SizedBox(),
                items: _times
                    .map<DropdownMenuItem<Time>>((_time) => DropdownMenuItem(
                          value: _time,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("~ " + _time.value),
                              Icon(Icons.circle,
                                  size: 15,
                                  color: _time.isAvailable == "T"
                                      ? Colors.green
                                      : Colors.red)
                            ],
                          ),
                        ))
                    .toList(),
              ),
      ],
    );
  }

  Widget _showPrimaryButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: ButtonTheme(
        minWidth: 250,
        // ignore: deprecated_member_use
        child: RaisedButton.icon(
          elevation: 8.0,
          icon: _isLoading
              ? circularProgressIndicator
              : Icon(Icons.bookmark, color: Colors.black),
          color: Colors.orange[600],
          label: Text(getTranslate(context, "BOOK_TICKET"),
              style: new TextStyle(fontSize: 15.0, color: Colors.black)),
          onPressed: _isLoading ||
                  _isFetchingTimes ||
                  _times.length == 0 ||
                  _selectedTime == null
              ? null
              : () => _getTicket(),
        ),
      ),
    );
  }

  Widget _showErrorMessage() {
    if (_error != null)
      return Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
        child: Text(
          _error,
          style: TextStyle(
              fontSize: 15.0, color: Colors.red, fontWeight: FontWeight.w400),
        ),
      );
    else
      return SizedBox.shrink();
  }

  Widget _showNotice() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 20.0),
      child: Text(
        getTranslate(context, "TICKET_NOTICE"),
        textAlign: TextAlign.justify,
        style: TextStyle(
            fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _incrementDecrement() {
    return Container(
      width: 60.0,
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(
          color: Colors.orange,
          width: 2.0,
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: TextFormField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(
                decimal: false,
                signed: true,
              ),
              inputFormatters: <TextInputFormatter>[
                // ignore: deprecated_member_use
                WhitelistingTextInputFormatter.digitsOnly
              ],
            ),
          ),
          Container(
            height: 38.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: InkWell(
                    child: Icon(
                      Icons.arrow_drop_up,
                      size: 18.0,
                    ),
                    onTap: () {
                      int currentValue = int.parse(_controller.text);
                      setState(() {
                        currentValue++;
                        _controller.text =
                            (currentValue).toString(); // incrementing value
                      });
                    },
                  ),
                ),
                InkWell(
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 18.0,
                  ),
                  onTap: () {
                    int currentValue = int.parse(_controller.text);
                    setState(() {
                      currentValue--;
                      _controller.text = (currentValue >= 1 ? currentValue : 1)
                          .toString(); // decrementing value
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          title: Text(widget.service.title),
          leading: IconButton(
            icon: Icon(Icons.navigate_before),
            onPressed: () => widget.callback(0),
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              getTranslate(context, "BOOK_TIKCET_MSG"),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            _showDatePicker(),
            SizedBox(
              height: 20,
            ),
            Text(
              getTranslate(context, "A"),
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 15,
            ),
            _showTimeInput(),
            _showNotice(),
            Divider(),
            Row(
              children: [
                Icon(Icons.notifications),
                Text(
                  getTranslate(context, "NOTIFICATIONS") + " :",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 05,
                ),
                Text(
                  getTranslate(context, "ALERT_BEFORE"),
                ),
                _incrementDecrement(),
                Text(
                  getTranslate(context, "ALERT_N") +
                      (int.parse(_controller.text) *
                              widget.service.timePerClient)
                          .toString() +
                      getTranslate(context, "ALERT_MN"),
                ),
                Spacer(),
                IconButton(
                    onPressed: () {
                      int _notifIndex = int.parse(_controller.text);
                      int _ticketNumber = _times.indexOf(_selectedTime) +
                          1 +
                          widget.service.counter;
                      if (_ticketNumber - _notifIndex <=
                          widget.service.counter) {
                        final snackBar = SnackBar(
                          content: Text(
                              getTranslate(context, "IMPOSS_ALERT_1") +
                                  _notifIndex.toString() +
                                  getTranslate(context, "IMPOSS_ALERT_2")),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        return;
                      }
                      if (!_notifications.contains(_notifIndex))
                        setState(() {
                          _notifications.add(_notifIndex);
                        });
                    },
                    icon: Icon(
                      Icons.add_circle,
                    ))
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 120,
              child: _notifications.length == 0
                  ? Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Text(
                        getTranslate(context, "NO_NOTIFICATIONS"),
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Scrollbar(
                      thickness: 10,
                      child: ListView.builder(
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _notifications
                                            .remove(_notifications[index]);
                                      });
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      size: 20,
                                    )),
                                Text(getTranslate(context, "ALERT_BEFORE")),
                                Text(_notifications[index].toString()),
                                Text(getTranslate(context, "ALERT_N") +
                                    (_notifications[index] *
                                            widget.service.timePerClient)
                                        .toString() +
                                    getTranslate(context, "ALERT_MN"))
                              ],
                            );
                          }),
                    ),
            ),
            _showErrorMessage(),
            _showPrimaryButton(),
          ],
        ));
  }
}

class Time {
  final String value;
  final String isAvailable;

  Time(this.value, this.isAvailable);
}
