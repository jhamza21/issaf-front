import 'dart:convert';

import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/ticket.dart';
import 'package:issaf/services/ticketService.dart';
import 'package:issaf/views/providers/line_chart.dart';
import 'package:issaf/views/providers/pie_chart.dart';

class Indicators extends StatefulWidget {
  final int serviceId;
  final void Function(int) callback;
  Indicators(this.serviceId, this.callback);
  @override
  _IndicatorsState createState() => _IndicatorsState();
}

class _IndicatorsState extends State<Indicators>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String _error;
  List<Ticket> _tickets = [];
  String _startDate = new DateFormat("yyyy-MM-dd")
          .format(DateTime.now().subtract(Duration(days: 7))),
      _endDate = new DateFormat("yyyy-MM-dd").format(DateTime.now());

  void initializeServiceData() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      var response = await TicketService().getTicketsByService(
          prefs.getString('token'), widget.serviceId, _startDate, _endDate);
      assert(response.statusCode == 200);
      var jsonData = json.decode(response.body);
      _tickets = Ticket.listFromJson(jsonData);
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
  void initState() {
    super.initState();
    initializeServiceData();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime d = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(isStart ? _startDate : _endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (d != null) {
      setState(() {
        if (isStart)
          _startDate = new DateFormat("yyyy-MM-dd").format(d);
        else
          _endDate = new DateFormat("yyyy-MM-dd").format(d);
      });
    }
  }

  Widget _showDatePicker(context, bool isStart) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.calendar_today),
        SizedBox(
          width: 20,
        ),
        InkWell(
          child: Text(isStart ? _startDate : _endDate,
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF000000))),
          onTap: () {
            _selectDate(context, isStart ? true : false);
          },
        ),
        SizedBox(
          width: 40,
        ),
      ],
    );
  }

  showFilterDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: Text(getTranslate(context, "FILTER_BY_PERIOD")),
              content: Container(
                height: 100,
                child: Column(children: [
                  Text(getTranslate(context, "FROM")),
                  _showDatePicker(context, true),
                  Text(getTranslate(context, "A")),
                  _showDatePicker(context, false),
                ]),
              ),
            );
          },
        );
      },
    ).then((value) => initializeServiceData());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.filter_alt),
              onPressed: () {
                showFilterDialog();
              },
            )
          ],
          leading: IconButton(
            icon: Icon(Icons.navigate_before),
            onPressed: () => widget.callback(0),
          ),
          bottom: _isLoading || _error != null
              ? null
              : TabBar(
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(icon: Icon(FontAwesomeIcons.chartPie)),
                    Tab(icon: Icon(FontAwesomeIcons.chartLine)),
                  ],
                ),
          title: Text(getTranslate(context, "STATISTICS")),
        ),
        body: _isLoading
            ? Center(child: circularProgressIndicator)
            : _error != null
                ? Center(
                    child: Text(_error),
                  )
                : TabBarView(
                    children: [
                      PieChart(_tickets, _startDate, _endDate),
                      LineChart(_tickets, _startDate, _endDate),
                    ],
                  ),
      ),
    );
  }
}
