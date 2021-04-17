import 'dart:convert';
import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/provider.dart';
import 'package:issaf/models/service.dart';
import 'package:issaf/services/serviceService.dart';
import 'package:issaf/views/clients/serviceDetails.dart';
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
      var prefs = await SharedPreferences.getInstance();
      final response = await ServiceService()
          .fetchServices(prefs.getString('token'), widget.provider.id);

      assert(response.statusCode == 200);
      final jsonData = json.decode(response.body)["services"];
      _services = Service.listFromJson(jsonData);
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectService(Service service) {
    if (service.requestStatus == "ACCEPTED" && service.status == "OPENED") {
      _selectedService = service;
      changePage(1);
    }
  }

  Widget serviceCard(Service service) {
    return GestureDetector(
      onTap: () => _selectService(service),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            )),
        child: ListTile(
          title: Text(
            service.title,
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15.0),
          ),
          subtitle: Text(
            service.description,
            style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.w600,
                fontSize: 15.0),
            overflow: TextOverflow.ellipsis,
          ),
          leading: CircleAvatar(
            backgroundColor: Colors.orange,
            radius: 30.0,
            backgroundImage:
                NetworkImage(URL_BACKEND + "serviceImg/" + service.image),
          ),
          trailing: Icon(
            Icons.circle,
            color: service.requestStatus == "ACCEPTED" &&
                    service.status == "OPENED"
                ? Colors.green
                : Colors.red,
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
              title: Text("E-Saffs"),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => widget.callback(0),
              ),
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
        : ServiceDetails(_selectedService, changePage);
  }
}
