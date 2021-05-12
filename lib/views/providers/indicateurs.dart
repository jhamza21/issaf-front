import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:issaf/constants.dart';
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
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.navigate_before),
            onPressed: () => widget.callback(0),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(FontAwesomeIcons.chartPie)),
              Tab(icon: Icon(FontAwesomeIcons.chartLine)),
            ],
          ),
          title: Text(getTranslate(context, "STATISTICS")),
        ),
        body: TabBarView(
          children: [
            PieChart(widget.serviceId),
            LineChart(widget.serviceId),
          ],
        ),
      ),
    );
  }
}
