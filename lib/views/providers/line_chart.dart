import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:issaf/constants.dart';
import 'package:issaf/models/ticket.dart';

class LineChart extends StatefulWidget {
  final List<Ticket> tickets;
  final String startDate;
  final String endDate;
  LineChart(this.tickets, this.startDate, this.endDate);
  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  List<charts.Series<Tickets, int>> _seriesLineData;
  List<Tickets> linedata = [];
  List<Ticket> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // ignore: deprecated_member_use
    _seriesLineData = List<charts.Series<Tickets, int>>();
    initializeChartData();
  }

  void initializeChartData() async {
    _tickets = widget.tickets;
    List<Ticket> present = _tickets.where((c) => c.status == "DONE").toList();
    for (int i = 0; i < present.length; i++) {
      linedata.add(Tickets(i, present[i].duration));
    }
    _seriesLineData.add(
      charts.Series(
        colorFn: (__, _) => charts.ColorUtil.fromDartColor(Colors.blue),
        id: 'avgTime',
        data: linedata,
        domainFn: (Tickets ticket, _) => ticket.period,
        measureFn: (Tickets ticket, _) => ticket.value,
      ),
    );
    setState(() {
      _isLoading = false;
    });
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
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      widget.startDate + " - " + widget.endDate,
                      style: TextStyle(fontSize: 12.0, color: Colors.grey),
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
