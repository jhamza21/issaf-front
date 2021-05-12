import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/services/serviceService.dart';
import 'package:issaf/views/responsables/bookTicket.dart';
import 'package:issaf/views/responsables/ticketsInProgress.dart';
import 'package:issaf/views/responsables/ticketsOld.dart';

class Tickets extends StatefulWidget {
  @override
  _TicketsState createState() => _TicketsState();
}

class _TicketsState extends State<Tickets> {
  int _currentIndex = 0;
  bool _isRegistredToService = false, _isLoading = true;

  void changePage(int i) {
    setState(() {
      _currentIndex = i;
    });
  }

  @override
  void initState() {
    super.initState();
    checkUserIsRegistredToService();
  }

  checkUserIsRegistredToService() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      var response =
          await ServiceService().getServiceByRespo(prefs.getString('token'));
      assert(response.statusCode == 200);
      setState(() {
        _isLoading = false;
        _isRegistredToService = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: mainBoxDecoration,
        child: Scaffold(
          appBar: _currentIndex == 0
              ? AppBar(
                  elevation: 0,
                  title: Text(getTranslate(context, 'MY_TICKETS')),
                  centerTitle: true,
                  actions: [
                    IconButton(
                        onPressed: _isLoading || !_isRegistredToService
                            ? null
                            : () => changePage(1),
                        icon: Icon(Icons.add))
                  ],
                  bottom: TabBar(
                    indicatorColor: Colors.white,
                    tabs: [
                      Tab(child: Text(getTranslate(context, "IN_PROGRESS"))),
                      Tab(child: Text(getTranslate(context, "HISTORICAL"))),
                    ],
                  ),
                )
              : null,
          body: _currentIndex == 0
              ? TabBarView(
                  children: [TicketsInProgress(), TicketsOld()],
                )
              : BookTicket(changePage, null),
        ),
      ),
    );
  }
}
