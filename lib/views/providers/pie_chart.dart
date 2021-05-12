import 'dart:convert';

import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:issaf/constants.dart';
import 'package:issaf/models/ticket.dart';
import 'package:issaf/services/serviceService.dart';

class PieChart extends StatefulWidget {
  final int serviceId;
  PieChart(this.serviceId);
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
    initializeServiceData();
    _seriesPieData.add(
      charts.Series(
        domainFn: (Tickets tickets, _) => tickets.name,
        measureFn: (Tickets tickets, _) => tickets.value,
        colorFn: (Tickets tickets, _) =>
            charts.ColorUtil.fromDartColor(tickets.colorval),
        id: 'Clients',
        data: piedata,
        labelAccessorFn: (Tickets row, _) => '${row.value}',
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
      _tickets = Ticket.listFromJson(jsonData);
      int present = _tickets.where((c) => c.status == "DONE").toList().length;
      int absent = _tickets.where((c) => c.status == "UNDONE").toList().length;
      int inProgress =
          _tickets.where((c) => c.status == "IN_PROGRESS").toList().length;
      if (present != 0)
        piedata.add(Tickets("Clients présents", present, Colors.green));
      if (absent != 0)
        piedata.add(Tickets("Clients absents", absent, Colors.red));
      if (inProgress != 0)
        piedata.add(Tickets("Clients en cours", inProgress, Colors.grey));

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
                      "Taux de tickets réservés",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
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
                    Text("Total clients : " + _tickets.length.toString())
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
