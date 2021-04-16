import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:commons/commons.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:issaf/models/service.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/user.dart';
import 'package:issaf/services/serviceService.dart';
import 'package:issaf/services/userService.dart';
import 'package:issaf/views/shared/selectDays.dart';

class ServiceDetails extends StatefulWidget {
  @override
  _ServiceDetailsState createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  final _formKey = new GlobalKey<FormState>();
  bool _isLoading = true;
  String _username,
      _title,
      _description,
      _workStartTime = "08:00",
      _workEndTime = "17:00",
      _status = "OPENED",
      _image,
      _error;

  double _avgTimePerClient = 10;
  List<String> _openDays = [];

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

      if (response.statusCode != 200) {
        setState(() {
          _error = "Vous n'appartenez pas à aucun service !";
          _isLoading = false;
        });
        return;
      }

      var jsonData = json.decode(response.body);
      Service _service = Service.fromJson(jsonData);
      if (_service.requestStatus != "ACCEPTED") {
        setState(() {
          _error = "Vous n'appartenez pas à aucun service !";
          _isLoading = false;
        });
        return;
      }
      _title = _service.title;
      _description = _service.description;
      _avgTimePerClient = _service.timePerClient.toDouble();
      _workStartTime = _service.workStartTime.substring(0, 5);
      _workEndTime = _service.workEndTime.substring(0, 5);
      _openDays = _service.openDays;
      _image = _service.image;
      _status = _service.status;
      response = await UserService()
          .getUserById(prefs.getString('token'), _service.userId);
      assert(response.statusCode == 200);
      jsonData = json.decode(response.body);
      _username = User.fromJson(jsonData).username;
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

  Widget showDescriptionInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        enabled: false,
        initialValue: _description,
        maxLines: 4,
        keyboardType: TextInputType.text,
        decoration: inputTextDecorationRectangle(
            null, getTranslate(context, 'DESCRIPTION') + "*", null, null),
        validator: (value) =>
            value.isEmpty || value.length < 8 || value.length > 255
                ? getTranslate(context, 'INVALID_DESCRIPTION_LENGTH')
                : null,
        onChanged: (value) => setState(() {
          _description = value.trim();
        }),
      ),
    );
  }

  Widget showImageInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: CircleAvatar(
          backgroundColor: Colors.orange[200],
          radius: 80,
          backgroundImage: _image != null
              ? NetworkImage("http://10.0.2.2:8000/api/serviceImg/" + _image)
              : null),
    );
  }

  Widget showTitleInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
        enabled: false,
        initialValue: _title,
        keyboardType: TextInputType.text,
        decoration: inputTextDecorationRectangle(
            null, getTranslate(context, 'TITLE') + "*", null, null),
        validator: (value) =>
            value.isEmpty || value.length < 2 || value.length > 255
                ? getTranslate(context, 'INVALID_TITLE_LENGTH')
                : null,
        onChanged: (value) => setState(() {
          _title = value.trim();
        }),
      ),
    );
  }

  Widget _showTimePicker(bool isStart, BuildContext context) {
    return Column(
      children: [
        Text(
          isStart
              ? getTranslate(context, "START")
              : getTranslate(context, "END"),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        IconButton(onPressed: () => {}, icon: Icon(Icons.alarm)),
        Text(isStart ? _workStartTime : _workEndTime),
      ],
    );
  }

  Widget showWorkTimeInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _showTimePicker(true, context),
          _showTimePicker(false, context)
        ],
      ),
    );
  }

  Widget showTitle(text) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget showDayPicker() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: SelectDays(
        border: false,
        initialValue: _openDays,
        boxDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            colors: [
              Colors.orange[300],
              Colors.orange[400],
            ],
            tileMode: TileMode.repeated,
          ),
        ),
        onSelect: (values) => {},
      ),
    );
  }

  Widget showUsernameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      child: new TextFormField(
        enabled: false,
        initialValue: _username,
        keyboardType: TextInputType.text,
        decoration: inputTextDecorationRectangle(
            null, getTranslate(context, 'USERNAME_RECEIVER') + "*", null, null),
        validator: (value) =>
            value.isEmpty || value.length < 6 || value.length > 255
                ? getTranslate(context, 'INVALID_USERNAME_LENGTH')
                : null,
        onChanged: (value) => setState(() {
          _username = value.trim();
        }),
      ),
    );
  }

  Widget showTimePerClientInput() {
    return Padding(
      child: SpinBox(
        min: 1,
        max: 240,
        value: _avgTimePerClient,
        onChanged: (value) => {},
        decoration: InputDecoration(
            labelText: getTranslate(context, "TIME_PER_CLIENT"),
            helperText: getTranslate(context, "TIME_PER_CLIENT_NOTICE")),
      ),
      padding: const EdgeInsets.all(16),
    );
  }

  Widget showStatusInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Row(
            children: [
              new Radio(
                  activeColor: Colors.black,
                  value: "OPENED",
                  groupValue: _status,
                  onChanged: (value) {}),
              new Text(
                getTranslate(context, "OPENED"),
                style: new TextStyle(fontSize: 16.0),
              ),
            ],
          ),
          Row(
            children: [
              new Radio(
                  activeColor: Colors.black,
                  value: "CLOSED",
                  groupValue: _status,
                  onChanged: (value) {}),
              new Text(
                getTranslate(context, "CLOSED"),
                style: new TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: mainBoxDecoration,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(getTranslate(context, "SERVICE_DETAILS")),
          centerTitle: true,
        ),
        body: _isLoading
            ? Center(
                child: circularProgressIndicator,
              )
            : _error != null
                ? Center(
                    child: Text(_error),
                  )
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          showImageInput(),
                          showUsernameInput(),
                          showTitleInput(),
                          showDescriptionInput(),
                          showTimePerClientInput(),
                          showTitle(getTranslate(context, "WORK_TIME")),
                          showWorkTimeInput(context),
                          showDayPicker(),
                          showStatusInput(),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
