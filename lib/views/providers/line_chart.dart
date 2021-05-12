import 'dart:convert';

import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:issaf/constants.dart';
import 'package:issaf/models/ticket.dart';
import 'package:issaf/services/serviceService.dart';

class LineChart extends StatefulWidget {
  final int serviceId;
  LineChart(this.serviceId);
  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  List<charts.Series<Tickets, int>> _seriesLineData =
      // ignore: deprecated_member_use
      List<charts.Series<Tickets, int>>();
  List<Tickets> linedata = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeServiceData();
    _seriesLineData.add(
      charts.Series(
        colorFn: (__, _) => charts.ColorUtil.fromDartColor(Colors.blue),
        id: 'Temps moyen par client',
        data: linedata,
        domainFn: (Tickets ticket, _) => ticket.period,
        measureFn: (Tickets ticket, _) => ticket.value,
      ),
    );
  }

  void initializeServiceData() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      var response = await ServiceService()
          .getServiceTickets(prefs.getString('token'), widget.serviceId);
      assert(response.statusCode == 200);
      var jsonData = json.decode(response.body);
      List<Ticket> _tickets = [];

      _tickets = Ticket.listFromJson(jsonData);
      List<Ticket> present = _tickets.where((c) => c.status == "DONE").toList();
      for (int i = 0; i < present.length; i++) {
        linedata.add(Tickets(i, present[i].duration));
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      final snackBar = SnackBar(
        content: Text(getTranslate(context, "ERROR_SERVER")),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        child: Center(
          child: _isLoading
              ? circularProgressIndicator
              : Column(
                  children: <Widget>[
                    Text(
                      getTranslate(context, "TIME_PER_CLIENT"),
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: charts.LineChart(
                        _seriesLineData,
                        defaultRenderer: new charts.LineRendererConfig(
                            includeArea: true, stacked: true),
                        animate: true,
                        animationDuration: Duration(seconds: 5),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class Tickets {
  int period;
  int value;

  Tickets(this.period, this.value);
}
