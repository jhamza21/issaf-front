import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:commons/commons.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:issaf/models/service.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/user.dart';
import 'package:issaf/services/serviceService.dart';
import 'package:issaf/services/userService.dart';
import 'package:issaf/views/shared/selectDays.dart';

class AddUpdateService extends StatefulWidget {
  final int idService;
  final void Function(int) callback;
  final void Function() fetchServices;
  AddUpdateService(this.idService, this.callback, this.fetchServices);
  @override
  _AddUpdateServiceState createState() => _AddUpdateServiceState();
}

class _AddUpdateServiceState extends State<AddUpdateService> {
  final _formKey = new GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  bool _isLoading = false, _isFetchingData = false;
  List<User> _selectedUsers = [];
  String _title,
      _description,
      _workStartTime = "08:00",
      _workEndTime = "17:00",
      _error,
      _errorTime,
      _errorDays;

  double _avgTimePerClient = 10;
  List<String> _openDays = [], _hoolidays = [], _breaks = [];
  File _selectedImage;
  Service _service;

  @override
  void initState() {
    super.initState();
    initializeServiceData();
  }

  void initializeServiceData() async {
    if (widget.idService != null)
      try {
        setState(() {
          _isFetchingData = true;
        });
        var prefs = await SharedPreferences.getInstance();
        var res = await ServiceService()
            .getServiceById(prefs.getString('token'), widget.idService);
        assert(res.statusCode == 200);
        _service = Service.fromJson(json.decode(res.body));
        _title = _service.title;
        _description = _service.description;
        _avgTimePerClient = _service.timePerClient.toDouble();
        _workStartTime = _service.workStartTime.substring(0, 5);
        _workEndTime = _service.workEndTime.substring(0, 5);
        _openDays = _service.openDays;
        _hoolidays = _service.hoolidays;
        _breaks = _service.breakTimes;
        _selectedUsers = _service.users;
        setState(() {
          _isFetchingData = false;
        });
      } catch (e) {
        final snackBar = SnackBar(
          content: Text(getTranslate(context, "ERROR_SERVER")),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        widget.callback(0);
      }
  }

  // bool checkServiceChanged(Service service) {
  //   if (service == null) return true;
  //   if (_title != service.title ||
  //       _selectedUser.id != service.userId ||
  //       _description != service.description ||
  //       _avgTimePerClient != service.timePerClient ||
  //       _workStartTime != service.workStartTime.substring(0, 5) ||
  //       _workEndTime != service.workEndTime.substring(0, 5) ||
  //       _openDays != service.openDays ||
  //       _hoolidays != service.hoolidays ||
  //       _breaks != service.breakTimes ||
  //       _selectedImage != null) return true;
  //   return false;
  // }

  // Check if form is valid
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate() && validateDays() && validateTime())
      return true;
    else
      return false;
  }

  // validate days
  bool validateDays() {
    setState(() {
      _errorDays = null;
    });
    if (_openDays.length > 0)
      return true;
    else {
      setState(() {
        _errorDays = getTranslate(context, "INVALID_DAYS");
      });
      return false;
    }
  }

  // validate work time
  bool validateTime() {
    setState(() {
      _errorTime = null;
    });
    TimeOfDay _startTime = TimeOfDay(
        hour: int.parse(_workStartTime.split(":")[0]),
        minute: int.parse(_workStartTime.split(":")[1]));
    TimeOfDay _endTime = TimeOfDay(
        hour: int.parse(_workEndTime.split(":")[0]),
        minute: int.parse(_workEndTime.split(":")[1]));
    if ((_startTime.hour + _startTime.minute / 60.0) <
        (_endTime.hour + _endTime.minute / 60.0))
      return true;
    else {
      setState(() {
        _errorTime = getTranslate(context, "INVALID_WORK_TIME");
      });
      return false;
    }
  }

  Widget showSaveService() {
    return TextButton.icon(
        onPressed: _isLoading
            ? null
            : () async {
                if (!_isLoading && validateAndSave())
                  try {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                    });
                    var prefs = await SharedPreferences.getInstance();
                    var res = await ServiceService().addUpdateService(
                        prefs.getString('token'),
                        widget.idService != null ? widget.idService : null,
                        _selectedUsers,
                        _title,
                        _description,
                        _avgTimePerClient.toInt().toString(),
                        _workStartTime,
                        _workEndTime,
                        _openDays,
                        _hoolidays,
                        _breaks,
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
        label: Text(getTranslate(context, "SAVE_CHANGES")));
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
      if (img != null) {
        if (File(img.path).lengthSync() >= 2097152) {
          final snackBar = SnackBar(
            content: Text(getTranslate(context, "FILE_SIZE_TOO_BIG")),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          return;
        }
        _selectedImage = File(img.path);
      }
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
                      (widget.idService != null && _service.image != null)
                  ? SizedBox.shrink()
                  : Text(getTranslate(context, "INSERT_IMAGE")),
              backgroundColor: Colors.orange[200],
              radius: 80,
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage)
                  : widget.idService != null && _service.image != null
                      ? NetworkImage(
                          URL_BACKEND + "serviceImg/" + _service.image)
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _showTimePicker(true, context),
              _showTimePicker(false, context)
            ],
          ),
          _errorTime != null
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 0.0),
                  child: Text(
                    _errorTime,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                )
              : SizedBox.shrink()
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
        errorText: _errorDays,
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

  GestureDetector _getSuffixIcon(User user) {
    return GestureDetector(
      child: Icon(
        Icons.circle,
        size: 15,
        color: user.status == null
            ? Colors.grey
            : user.status == "ACCEPTED"
                ? Colors.green[800]
                : Colors.red[800],
      ),
    );
  }

  bool contains(User user, List<User> users) {
    for (User u in users) {
      if (user.id == u.id) return true;
    }
    return false;
  }

  Widget showUsernameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 0.0),
      child: Column(
        children: [
          new TypeAheadFormField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _typeAheadController,
                decoration: inputTextDecorationRectangle(null,
                    getTranslate(context, 'USERNAME_RECEIVER'), null, null),
              ),
              suggestionsCallback: UserService().getUserSuggestions,
              hideSuggestionsOnKeyboardHide: false,
              debounceDuration: Duration(milliseconds: 500),
              noItemsFoundBuilder: (context) => Container(
                    height: 100,
                    child: Center(
                      child: Text(getTranslate(context, "NO_RESULT_FOUND")),
                    ),
                  ),
              itemBuilder: (context, User user) {
                return ListTile(
                  title: Row(
                    children: [
                      Text(user.name),
                      Text(
                        " (" + user.username + ")",
                        style: TextStyle(fontSize: 13, color: Colors.orange),
                      ),
                    ],
                  ),
                  subtitle: Text(user.email),
                );
              },
              onSuggestionSelected: (User user) {
                _typeAheadController.text = "";
                if (!contains(user, _selectedUsers))
                  setState(() {
                    _selectedUsers.add(user);
                  });
              }),
          Container(
            height: 120,
            child: _selectedUsers.length == 0
                ? Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Text(
                      "Pas d'opérateurs séléctionnés",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Scrollbar(
                    thickness: 10,
                    child: ListView.builder(
                        itemCount: _selectedUsers.length,
                        itemBuilder: (BuildContext context, int index) {
                          return new ListTile(
                            title: Row(
                              children: [
                                Text(_selectedUsers[index].name),
                                Text(
                                  " (" + _selectedUsers[index].username + ")",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.orange),
                                ),
                              ],
                            ),
                            subtitle: Text(_selectedUsers[index].email),
                            leading: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.black,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedUsers.removeWhere((element) =>
                                      element.id == _selectedUsers[index].id);
                                });
                              },
                            ),
                            trailing: _getSuffixIcon(_selectedUsers[index]),
                          );
                        }),
                  ),
          ),
        ],
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
      ),
      padding: const EdgeInsets.all(16),
    );
  }

  // void _handleRadioButton(String value) {
  //   setState(() {
  //     _status = value;
  //   });
  // }

  // Widget showStatusInput() {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(12.0, 15.0, 12.0, 0.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: <Widget>[
  //         Row(
  //           children: [
  //             new Radio(
  //                 activeColor: Colors.black,
  //                 value: "OPENED",
  //                 groupValue: _status,
  //                 onChanged: _handleRadioButton),
  //             new Text(
  //               getTranslate(context, "OPENED"),
  //               style: new TextStyle(fontSize: 16.0),
  //             ),
  //           ],
  //         ),
  //         Row(
  //           children: [
  //             new Radio(
  //                 activeColor: Colors.black,
  //                 value: "CLOSED",
  //                 groupValue: _status,
  //                 onChanged: _handleRadioButton),
  //             new Text(
  //               getTranslate(context, "CLOSED"),
  //               style: new TextStyle(
  //                 fontSize: 16.0,
  //               ),
  //             ),
  //           ],
  //         )
  //       ],
  //     ),
  //   );
  // }

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
      _break = _s.format(context) + " -> ";
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
          title: Text(widget.idService == null
              ? getTranslate(context, "ADD_SERVICE")
              : _isFetchingData
                  ? "..."
                  : _service.title),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.navigate_before),
            onPressed: () => widget.callback(0),
          ),
        ),
        body: _isFetchingData
            ? Center(
                child: circularProgressIndicator,
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      showImageInput(),
                      showTitleInput(),
                      showDescriptionInput(),
                      showTitle(getTranslate(context, "OPERATORS")),
                      showUsernameInput(),
                      showTitle(getTranslate(context, "WORK_TIME")),
                      showWorkTimeInput(context),
                      showDayPicker(),
                      showTitle(getTranslate(context, "TIME_PER_CLIENT")),
                      showTimePerClientInput(),
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
