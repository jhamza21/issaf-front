import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:commons/commons.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:issaf/models/provider.dart' as ModelProvider;
import 'package:issaf/models/service.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/user.dart';
import 'package:issaf/services/serviceService.dart';
import 'package:issaf/services/userService.dart';
import 'package:issaf/views/shared/selectDays.dart';

class AddUpdateService extends StatefulWidget {
  final ModelProvider.Provider provider;
  final Service service;
  final void Function(int) callback;
  AddUpdateService(this.provider, this.service, this.callback);
  @override
  _AddUpdateServiceState createState() => _AddUpdateServiceState();
}

class _AddUpdateServiceState extends State<AddUpdateService> {
  final _formKey = new GlobalKey<FormState>();
  bool _isLoading = false;
  String _username,
      _prevUsername,
      _title,
      _description,
      _workStartTime = "08:00",
      _workEndTime = "17:00",
      _status = "OPENED",
      _error;

  double _avgTimePerClient = 10;
  List<String> _openDays = [];
  File _selectedImage;
  bool _isFetchingUser = false;

  @override
  void initState() {
    super.initState();
    initializeUserData();
  }

  void initializeUserData() async {
    if (widget.service != null)
      try {
        setState(() {
          _isFetchingUser = true;
        });
        _title = widget.service.title;
        _description = widget.service.description;
        _avgTimePerClient = widget.service.timePerClient.toDouble();
        _workStartTime = widget.service.workStartTime.substring(0, 5);
        _workEndTime = widget.service.workEndTime.substring(0, 5);
        _openDays = widget.service.openDays;
        _status = widget.service.status;
        var prefs = await SharedPreferences.getInstance();
        final response = await UserService()
            .getUserById(prefs.getString('token'), widget.service.userId);
        assert(response.statusCode == 200);
        final jsonData = json.decode(response.body);
        _username = User.fromJson(jsonData).username;
        _prevUsername = User.fromJson(jsonData).username;
        setState(() {
          _isFetchingUser = false;
        });
      } catch (e) {
        widget.callback(0);
      }
  }

  bool checkServiceChanged(Service service) {
    if (service == null) return true;
    if (_title != service.title ||
        _username != _prevUsername ||
        _description != service.description ||
        _avgTimePerClient != service.timePerClient ||
        _workStartTime != service.workStartTime.substring(0, 5) ||
        _workEndTime != service.workEndTime.substring(0, 5) ||
        _openDays != service.openDays ||
        _status != service.status ||
        _selectedImage != null) return true;
    return false;
  }

  bool validateImage() {
    if (_selectedImage != null ||
        (widget.service != null && widget.service.image != null)) return true;

    return false;
  }

  // Check if form is valid
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate() && validateImage()) return true;
    return false;
  }

  Widget showSaveService() {
    return checkServiceChanged(widget.service)
        ? TextButton.icon(
            onPressed: () async {
              if (!_isLoading && validateAndSave())
                try {
                  setState(() {
                    _error = null;
                    _isLoading = true;
                  });
                  var prefs = await SharedPreferences.getInstance();
                  var res = await ServiceService().addUpdateService(
                      prefs.getString('token'),
                      widget.service.id,
                      _title,
                      _description,
                      _avgTimePerClient.toInt().toString(),
                      "0",
                      _workStartTime,
                      _workEndTime,
                      _openDays,
                      _status,
                      _selectedImage);
                  if (res.statusCode == 201 || res.statusCode == 200) {
                    final snackBar = SnackBar(
                      content: Text(getTranslate(
                          context,
                          res.statusCode == 201
                              ? "SUCCESS_ADD"
                              : "SUCCESS_UPDATE")),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    widget.callback(0);
                  } else {
                    final jsonData =
                        json.decode(await res.stream.bytesToString());
                    setState(() {
                      _isLoading = false;
                      _error = getTranslate(context, jsonData["error"]);
                    });
                  }
                } catch (e) {
                  print(e);
                  setState(() {
                    _isLoading = false;
                    _error = getTranslate(context, "ERROR_SERVER");
                  });
                }
            },
            icon: _isLoading ? circularProgressIndicator : Icon(Icons.save),
            label: Text(getTranslate(context, "SAVE_CHANGES")))
        : SizedBox.shrink();
  }

  Widget showError() {
    return _error != null
        ? Padding(
            padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 0.0),
            child: Text(
              _error,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          )
        : SizedBox.shrink();
  }

  Widget showDescriptionInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
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

  Future getImageFromGallery() async {
    var img = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      if (img != null) _selectedImage = File(img.path);
    });
  }

  Widget showImageInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
              child: _selectedImage == null && widget.service == null
                  ? Text(getTranslate(context, "INSERT_IMAGE") + "*")
                  : SizedBox.shrink(),
              backgroundColor: Colors.orange[200],
              radius: 80,
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage)
                  : widget.service != null
                      ? NetworkImage("http://10.0.2.2:8000/api/serviceImg/" +
                          widget.service.image)
                      : null),
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.grey[600]),
                onPressed: () {
                  getImageFromGallery();
                },
              ),
              IconButton(
                icon: Icon(Icons.restore,
                    color: _selectedImage != null
                        ? Colors.grey[600]
                        : Colors.grey[400]),
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget showTitleInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: TextFormField(
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

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    TimeOfDay selectedTime = TimeOfDay.now();
    TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null)
      setState(() {
        if (isStart)
          _workStartTime = picked.format(context);
        else
          _workEndTime = picked.format(context);
      });
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
        IconButton(
            onPressed: () => _selectTime(context, isStart),
            icon: Icon(Icons.alarm)),
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
        onSelect: (values) => setState(() {
          _openDays = values;
        }),
      ),
    );
  }

  Widget showUsernameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      child: new TextFormField(
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
        onChanged: (value) => setState(() {
          _avgTimePerClient = value;
        }),
        decoration: InputDecoration(
            labelText: getTranslate(context, "TIME_PER_CLIENT"),
            helperText: getTranslate(context, "TIME_PER_CLIENT_NOTICE")),
      ),
      padding: const EdgeInsets.all(16),
    );
  }

  void _handleRadioButton(String value) {
    setState(() {
      _status = value;
    });
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
                  onChanged: _handleRadioButton),
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
                  onChanged: _handleRadioButton),
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
          title: Text(getTranslate(context, "ADD_SERVICE")),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => widget.callback(0),
          ),
        ),
        body: _isFetchingUser
            ? Center(
                child: circularProgressIndicator,
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
                      showError(),
                      showSaveService()
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
