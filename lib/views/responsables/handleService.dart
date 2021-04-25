import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/service.dart';
import 'package:issaf/services/serviceService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HandleService extends StatefulWidget {
  @override
  _HandleServiceState createState() => _HandleServiceState();
}

class _HandleServiceState extends State<HandleService> {
  bool _isLoading = true;
  String _error;
  int _counter;

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
      if (response.statusCode == 404) {
        _error = getTranslate(context, "REGISTE_TO_SERVER");
        setState(() {
          _isLoading = false;
        });
        return;
      }
      assert(response.statusCode == 200);
      var jsonData = json.decode(response.body);
      Service _service = Service.fromJson(jsonData);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        // actions: [IconButton(onPressed: () {}, icon: Icon(Icons.qr_code))],
        title: Text(getTranslate(context, "HOME")),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ButtonTheme(
                            minWidth: 150,
                            // ignore: deprecated_member_use
                            child: RaisedButton.icon(
                              elevation: 5.0,
                              icon: Icon(Icons.done),
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(30.0)),
                              color: Colors.green[900],
                              label: Text(getTranslate(context, "DONE")),
                              onPressed: () {},
                            ),
                          ),
                          ButtonTheme(
                            minWidth: 150,
                            // ignore: deprecated_member_use
                            child: RaisedButton.icon(
                              elevation: 5.0,
                              icon: Icon(Icons.dangerous),
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(30.0)),
                              color: Colors.red[900],
                              label: Text(getTranslate(context, "UNDONE")),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
      ),
    );
  }
}
