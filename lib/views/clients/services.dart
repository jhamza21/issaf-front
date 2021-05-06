import 'dart:convert';
import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/provider.dart';
import 'package:issaf/models/service.dart';
import 'package:issaf/services/serviceService.dart';
import 'package:issaf/views/clients/bookTicket.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceList extends StatefulWidget {
  final Provider provider;
  final void Function(int) callback;

  ServiceList(this.provider, this.callback);

  @override
  _ServiceListState createState() => _ServiceListState();
}

@override
class _ServiceListState extends State<ServiceList> {
  Service _selectedService;
  List<Service> _services = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  void _fetchServices() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var prefs = await SharedPreferences.getInstance();
      final response = await ServiceService()
          .fetchServices(prefs.getString('token'), widget.provider.id);

      assert(response.statusCode == 200);
      final jsonData = json.decode(response.body)["services"];
      _services = Service.listFromJson(jsonData);
      //filter active services
      _services.removeWhere((element) => element.status != "ACCEPTED");
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      final snackBar = SnackBar(
        content: Text(getTranslate(context, "ERROR_SERVER")),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _selectService(Service service) {
    _selectedService = service;
    changePage(1);
  }

  Widget _getOpenDays(Service service) {
    // ignore: deprecated_member_use
    List<Widget> list = new List<Widget>();
    list.add(Icon(Icons.calendar_today));
    list.add(Text(" : "));
    for (var i = 0; i < service.openDays.length; i++) {
      list.add(
          new Text(getTranslate(context, service.openDays[i].toUpperCase())));
      list.add(Text(", "));
    }
    return new Row(children: list);
  }

  void _showServiceInfo(Service service) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return customDialog(
              service.title,
              service.description,
              service.image != null ? "serviceImg/" + service.image : null,
              Column(
                children: [
                  Text(
                    getTranslate(context, "CLIENT_NUMBER") +
                        " " +
                        service.counter.toString(),
                    style: TextStyle(
                        backgroundColor: Colors.orange,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined),
                      Expanded(
                          child: Text(
                              " : " + service.workStartTime.substring(0, 5)))
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.timer_off),
                      Expanded(
                          child:
                              Text(" : " + service.workEndTime.substring(0, 5)))
                    ],
                  ),
                  _getOpenDays(service)
                ],
              ));
        });
  }

  Widget serviceCard(Service service) {
    return GestureDetector(
      onTap: () => _selectService(service),
      child: Card(
        color: Colors.orange[50],
        child: ListTile(
          dense: true,
          title: Text(
            service.title,
          ),
          subtitle: Text(
            service.description,
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.orange,
            child: service.image == null
                ? Text(
                    service.title[0].toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  )
                : SizedBox.shrink(),
            radius: 30.0,
            backgroundImage: service.image != null
                ? NetworkImage(URL_BACKEND + "serviceImg/" + service.image)
                : null,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Icon(
                  Icons.info,
                  size: 17,
                ),
                onPressed: () {
                  _showServiceInfo(service);
                },
              ),
              SizedBox(
                width: 15,
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _currentIndex == 0
        ? Scaffold(
            appBar: AppBar(
              centerTitle: true,
              elevation: 0.0,
              title:
                  Text(widget.provider.title, style: TextStyle(fontSize: 17)),
              leading: IconButton(
                icon: Icon(Icons.navigate_before),
                onPressed: () => widget.callback(0),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _isLoading ? null : () => _fetchServices(),
                ),
              ],
            ),
            body: _isLoading
                ? Center(child: circularProgressIndicator)
                : _services.length == 0
                    ? Center(
                        child: Text(getTranslate(context, "NO_RESULT_FOUND")),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(8),
                        itemCount: _services.length,
                        itemBuilder: (context, index) {
                          return serviceCard(_services[index]);
                        },
                      ))
        : BookTicket(_selectedService, changePage, null);
  }
}
