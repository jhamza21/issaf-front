import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:commons/commons.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:issaf/models/provider.dart' as ModelProvider;
import 'package:issaf/models/service.dart';
import 'package:issaf/models/request.dart' as ModelRequest;
import 'package:issaf/constants.dart';
import 'package:issaf/models/user.dart';
import 'package:issaf/services/requestService.dart';
import 'package:issaf/services/serviceService.dart';
import 'package:issaf/services/userService.dart';
import 'package:issaf/views/shared/selectDays.dart';

class AddUpdateService extends StatefulWidget {
  final ModelProvider.Provider provider;
  final Service service;
  final void Function(int) callback;
  final void Function() fetchServices;
  AddUpdateService(
      this.provider, this.service, this.callback, this.fetchServices);
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
  List<String> _openDays = [], _hoolidays = [], _breaks = [];
  File _selectedImage;
  bool _isFetchingUser = false, _requestStatus = false;

  @override
  void initState() {
    super.initState();
    initializeServiceData();
  }

  void initializeServiceData() async {
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
        _hoolidays = widget.service.hoolidays;
        _breaks = widget.service.breakTimes;
        _status = widget.service.status;
        var prefs = await SharedPreferences.getInstance();
        if (widget.service.userId != null) {
          _requestStatus = true;
          _prevUsername = _username = await _getUsername(
              prefs.getString('token'), widget.service.userId);
        } else {
          final response = await RequestService().fetchRequestByServiceId(
              prefs.getString('token'), widget.service.id);
          if (response.statusCode == 200) {
            final jsonData = json.decode(response.body);
            var _request = ModelRequest.Request.fromJson(jsonData);
            if (_request.status == "REFUSED") {
              _requestStatus = false;
              _prevUsername = _username = await _getUsername(
                  prefs.getString('token'), _request.senderId);
            } else if (_request.status == null) {
              _requestStatus = null;
              _prevUsername = _username = await _getUsername(
                  prefs.getString('token'), _request.receiverId);
            }
          } else {
            _requestStatus = false;
            _prevUsername = _username = null;
          }
        }
        setState(() {
          _isFetchingUser = false;
        });
      } catch (e) {
        widget.callback(0);
      }
  }

  Future<String> _getUsername(String token, int id) async {
    final response = await UserService().getUserById(token, id);
    assert(response.statusCode == 200);
    final jsonData = json.decode(response.body);
    return User.fromJson(jsonData).username;
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
        _hoolidays != service.hoolidays ||
        _breaks != service.breakTimes ||
        _status != service.status ||
        _selectedImage != null) return true;
    return false;
  }

  // Check if form is valid
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate())
      return true;
    else
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
                      widget.service != null ? widget.service.id : null,
                      widget.provider.id,
                      _prevUsername != _username ? _username : null,
                      _title,
                      _description,
                      _avgTimePerClient.toInt().toString(),
                      "0",
                      _workStartTime,
                      _workEndTime,
                      _openDays,
                      _hoolidays,
                      _breaks,
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
                    widget.fetchServices();
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
              child: _selectedImage != null ||
                      (widget.service != null && widget.service.image != null)
                  ? SizedBox.shrink()
                  : Text(getTranslate(context, "INSERT_IMAGE")),
              backgroundColor: Colors.orange[200],
              radius: 80,
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage)
                  : widget.service != null
                      ? NetworkImage(
                          URL_BACKEND + "serviceImg/" + widget.service.image)
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
      padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
      child: Container(
        alignment: Alignment.topLeft,
        child: Text(
          "- " + text + " :",
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
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

  GestureDetector _getSuffixIcon() {
    if (widget.service == null)
      return null;
    else
      return GestureDetector(
        child: Icon(
          Icons.circle,
          color: _requestStatus == true
              ? Colors.green[800]
              : _requestStatus == false
                  ? Colors.red[800]
                  : Colors.grey,
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
            null,
            getTranslate(context, 'USERNAME_RECEIVER') + "*",
            null,
            _getSuffixIcon()),
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
            labelText: getTranslate(context, "TIME_PER_CLIENT")),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (d != null) {
      String _date = new DateFormat("yyyy-MM-dd").format(d);
      if (_hoolidays.contains(_date)) {
        final snackBar = SnackBar(
          content: Text(getTranslate(context, "DUPLICATED_HOOLIDAYS")),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else
        setState(() {
          _hoolidays.add(_date);
        });
    }
  }

  Widget _showHoolidaysInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 5.0, 15.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          DropdownButton(
            dropdownColor: Colors.orange[50],
            value: _hoolidays.length > 0
                ? _hoolidays[_hoolidays.length - 1]
                : null,
            icon: Icon(
              Icons.arrow_drop_down,
            ),
            onChanged: (v) {},
            underline: SizedBox(),
            items: _hoolidays
                .map<DropdownMenuItem<String>>((date) => DropdownMenuItem(
                      value: date,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _hoolidays.remove(date);
                              });
                            },
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(date),
                          SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () {
              _selectDate(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectBreakTime(BuildContext context) async {
    TimeOfDay selectedTime = TimeOfDay.now();
    TimeOfDay _s = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        helpText: getTranslate(context, "INSERT_TIME_BREAK_START"));
    String _break;

    if (_s != null) {
      _break = _s.format(context) + " à ";
      TimeOfDay _e = await showTimePicker(
          context: context,
          initialTime: selectedTime,
          helpText: getTranslate(context, "INSERT_TIME_BREAK_END"));
      if (_e != null) {
        if ((_s.hour + _s.minute / 60.0) >= (_e.hour + _e.minute / 60.0)) {
          final snackBar = SnackBar(
            content: Text(getTranslate(context, "INVALID_BREAK_TIME")),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          _break += _e.format(context);
          setState(() {
            _breaks.add(_break);
          });
        }
      }
    }
  }

  Widget _showTimeBreaksInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 15.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          DropdownButton(
            dropdownColor: Colors.orange[50],
            value: _breaks.length > 0 ? _breaks[_breaks.length - 1] : null,
            icon: Icon(
              Icons.arrow_drop_down,
            ),
            onChanged: (v) {},
            underline: SizedBox(),
            items: _breaks
                .map<DropdownMenuItem<String>>((_break) => DropdownMenuItem(
                      value: _break,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _breaks.remove(_break);
                              });
                            },
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(_break),
                          SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
          IconButton(
            icon: Icon(Icons.add_circle),
            onPressed: () {
              _selectBreakTime(context);
            },
          ),
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
          title: Text(getTranslate(context,
              widget.service == null ? "ADD_SERVICE" : "UPDATE_SERVICE")),
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
                      showTitle(getTranslate(context, "HOOLIDAYS")),
                      _showHoolidaysInput(context),
                      showTitle(getTranslate(context, "BREAK_TIMES")),
                      _showTimeBreaksInput(context),
                      // showStatusInput(),
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
