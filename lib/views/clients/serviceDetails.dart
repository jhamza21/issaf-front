import 'dart:convert';

import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/service.dart';
import 'package:issaf/services/ticketService.dart';

class ServiceDetails extends StatefulWidget {
  final Service service;
  final void Function(int) callback;
  ServiceDetails(this.service, this.callback);
  @override
  _ServiceDetailsState createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  String _selectedDate = new DateFormat("yyyy-MM-dd").format(DateTime.now());
  String _selectedTime, _error;
  bool _isLoading = false, _isFetchingTimes;
  List<String> _times;

  @override
  void initState() {
    super.initState();
    _fetchAvailableTimes();
  }

  void _fetchAvailableTimes() async {
    try {
      setState(() {
        _isFetchingTimes = true;
        _error = null;
      });
      _times = null;
      var prefs = await SharedPreferences.getInstance();
      var res = await TicketService().fetchAvailableTicketsByDat(
          prefs.getString('token'),
          _selectedDate,
          widget.service.id.toString());
      assert(res.statusCode == 200);
      setState(() {
        _times = (json.decode(res.body) as List<dynamic>).cast<String>();
        if (_times.length > 0) _selectedTime = _times[0];
        _isFetchingTimes = false;
      });
    } catch (e) {
      setState(() {
        _times = null;
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
      var res = await TicketService().addTicket(
          prefs.getString('token'),
          _selectedDate,
          _selectedTime,
          _times.indexOf(_selectedTime) + 1,
          widget.service.id);
      if (res.statusCode == 201) {
        final snackBar = SnackBar(
          content: Text(getTranslate(context, "SUCCESS_ADD")),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                onChanged: (String value) {
                  setState(() {
                    _selectedTime = value;
                  });
                },
                underline: SizedBox(),
                items: _times != null
                    ? _times
                        .map<DropdownMenuItem<String>>(
                            (_time) => DropdownMenuItem(
                                  value: _time,
                                  child: Text(_time),
                                ))
                        .toList()
                    : null,
              ),
      ],
    );
  }

  Widget _showPrimaryButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
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
          onPressed: () {
            _getTicket();
          },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          title: Text(widget.service.title),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => widget.callback(0),
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 60,
            ),
            Text(
              getTranslate(context, "BOOK_TIKCET_MSG"),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 50,
            ),
            _showDatePicker(),
            SizedBox(
              height: 30,
            ),
            Text(
              getTranslate(context, "A"),
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 30,
            ),
            _showTimeInput(),
            SizedBox(
              height: 10,
            ),
            _showErrorMessage(),
            _showPrimaryButton()
          ],
        ));
  }
}
