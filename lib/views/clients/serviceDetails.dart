import 'package:flutter/material.dart';
import 'package:issaf/models/service.dart';

class ServiceDetails extends StatefulWidget {
  final Service service;
  final void Function(int) callback;
  ServiceDetails(this.service, this.callback);
  @override
  _ServiceDetailsState createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
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
        body: Container());
  }
}
