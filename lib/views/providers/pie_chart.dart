import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:issaf/constants.dart';
import 'package:issaf/models/ticket.dart';

class PieChart extends StatefulWidget {
  final List<Ticket> tickets;
  final String startDate;
  final String endDate;
  PieChart(this.tickets, this.startDate, this.endDate);
  @override
  _PieChartState createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  bool _isLoading = true;
  List<charts.Series<Tickets, String>> _seriesPieData =
      // ignore: deprecated_member_use
      List<charts.Series<Tickets, String>>();
  List<Tickets> piedata = [];
  List<Ticket> _tickets = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      initializeChartData();
    });
  }

  void initializeChartData() async {
    _tickets = widget.tickets;
    int present = _tickets.where((c) => c.status == "DONE").toList().length;
    int absent = _tickets.where((c) => c.status == "UNDONE").toList().length;
    int inProgress =
        _tickets.where((c) => c.status == "IN_PROGRESS").toList().length;
    if (present != 0)
      piedata.add(Tickets(
          getTranslate(context, "PRESENT_CLIENTS"), present, Colors.green));
    if (absent != 0)
      piedata.add(
          Tickets(getTranslate(context, "ABSENT_CLIENTS"), absent, Colors.red));
    if (inProgress != 0)
      piedata.add(Tickets(getTranslate(context, "IN_PROGRESS_CLIENTS"),
          inProgress, Colors.grey));
    _seriesPieData.add(
      charts.Series(
        domainFn: (Tickets tickets, _) => tickets.name,
        measureFn: (Tickets tickets, _) => tickets.value,
        colorFn: (Tickets tickets, _) =>
            charts.ColorUtil.fromDartColor(tickets.colorval),
        id: 'presentClients',
        data: piedata,
        labelAccessorFn: (Tickets row, _) => '${row.value}',
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
                      getTranslate(context, "CHART_PRESENT_CLIENTS"),
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      widget.startDate + " - " + widget.endDate,
                      style: TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Expanded(
                      child: charts.PieChart(_seriesPieData,
                          animate: true,
                          animationDuration: Duration(seconds: 5),
                          behaviors: [
                            new charts.DatumLegend(
                              outsideJustification:
                                  charts.OutsideJustification.endDrawArea,
                              horizontalFirst: false,
                              cellPadding:
                                  new EdgeInsets.only(right: 4.0, bottom: 4.0),
                              entryTextStyle: charts.TextStyleSpec(
                                  color: charts
                                      .MaterialPalette.purple.shadeDefault,
                                  fontFamily: 'Georgia',
                                  fontSize: 11),
                            )
                          ],
                          defaultRenderer: new charts.ArcRendererConfig(
                              arcWidth: 100,
                              arcRendererDecorators: [
                                new charts.ArcLabelDecorator(
                                    labelPosition:
                                        charts.ArcLabelPosition.inside)
                              ])),
                    ),
                    Text(getTranslate(context, "TOTAL_CLIENTS") +
                        _tickets.length.toString())
                  ],
                ),
        ),
      ),
    );
  }
}

class Tickets {
  String name;
  int value;
  Color colorval;

  Tickets(this.name, this.value, this.colorval);
}
