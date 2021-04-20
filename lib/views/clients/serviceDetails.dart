import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/service.dart';

class ServiceDetails extends StatefulWidget {
  final Service service;
  final void Function(int) callback;
  ServiceDetails(this.service, this.callback);
  @override
  _ServiceDetailsState createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  String _selectedDate = new DateFormat("yyyy-MM-dd").format(DateTime.now());
  String _selectedTime;
  bool _isLoading = false;
  List<String> _times = ["08:00", "08:30", "09:00", "10:00"];

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
        DropdownButton(
          dropdownColor: Colors.orange[50],
          value: _times[0],
          onChanged: (String value) {
            setState(() {
              _selectedTime = value;
            });
          },
          underline: SizedBox(),
          items: _times
              .map<DropdownMenuItem<String>>((_time) => DropdownMenuItem(
                    value: _time,
                    child: Text(_time),
                  ))
              .toList(),
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
          label: Text("Prendre ce ticket".toUpperCase(),
              style: new TextStyle(fontSize: 15.0, color: Colors.black)),
          onPressed: () {},
        ),
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
              "Je souhaite passer le :",
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
              "à",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 30,
            ),
            _showTimeInput(),
            SizedBox(
              height: 10,
            ),
            _showPrimaryButton()
          ],
        ));
  }
}
