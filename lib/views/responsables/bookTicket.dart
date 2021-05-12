import 'dart:convert';

import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/services/ticketService.dart';

class BookTicket extends StatefulWidget {
  final void Function(int) callback;
  final void Function() fetchTickets;
  BookTicket(this.callback, this.fetchTickets);
  @override
  _BookTicketState createState() => _BookTicketState();
}

class _BookTicketState extends State<BookTicket> {
  String _selectedDate = new DateFormat("yyyy-MM-dd").format(DateTime.now()),
      _name,
      _error;
  final _formKey = new GlobalKey<FormState>();
  Time _selectedTime;
  bool _isLoading = false, _isFetchingTimes;
  List<Time> _times = [];
  List<Time> _timesOnlyAvailable = [];
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAvailableTimes();
    _controller.text = "1"; // Setting the initial value for the field.
  }

  // Check if form is valid
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _fetchAvailableTimes() async {
    try {
      setState(() {
        _isFetchingTimes = true;
        _error = null;
      });
      var prefs = await SharedPreferences.getInstance();
      var res = await TicketService().fetchAvailableTicketsByDat(
          prefs.getString('token'), _selectedDate, "-1");
      assert(res.statusCode == 200);
      json
          .decode(res.body)
          .entries
          .forEach((entry) => _times.add(Time(entry.key, entry.value)));
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

  Widget buildNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40.0, 15.0, 40.0, 0.0),
      child: new TextFormField(
        initialValue: _name,
        keyboardType: TextInputType.text,
        decoration: inputTextDecorationRectangle(Icon(Icons.person),
            getTranslate(context, 'NAME') + "*", null, null),
        validator: (value) =>
            value.isEmpty || value.length < 6 || value.length > 255
                ? getTranslate(context, 'INVALID_NAME_LENGTH')
                : null,
        onSaved: (value) => _name = value.trim(),
      ),
    );
  }

//book ticket
  void _getTicket() async {
    if (validateAndSave()) {
      try {
        setState(() {
          _isLoading = true;
          _error = null;
        });
        var prefs = await SharedPreferences.getInstance();
        var res = await TicketService().addTicketRespo(
            prefs.getString('token'),
            _selectedDate,
            _selectedTime.value,
            _timesOnlyAvailable.indexOf(_selectedTime) + 1,
            _name);
        if (res.statusCode == 201) {
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
                      content: Text("Cet ticket n'est plus disponible !"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          title: Text("Réserver un ticket"),
          leading: IconButton(
            icon: Icon(Icons.navigate_before),
            onPressed: () => widget.callback(0),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _isLoading || _isFetchingTimes
                  ? null
                  : () => _fetchAvailableTimes(),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                "Réserver un ticket pour :",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              buildNameInput(),
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
              _showErrorMessage(),
              _showPrimaryButton(),
              Spacer(),
              _showNotice(),
            ],
          ),
        ));
  }
}

class Time {
  final String value;
  final String isAvailable;

  Time(this.value, this.isAvailable);
}
