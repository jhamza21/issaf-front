import 'dart:convert';
import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/service.dart';
import 'package:issaf/services/serviceService.dart';
import 'package:issaf/views/providers/addUpdateService.dart';
import 'package:issaf/views/providers/indicateurs.dart';
import 'package:issaf/views/responsables/handleService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceList extends StatefulWidget {
  @override
  _ServiceListState createState() => _ServiceListState();
}

@override
class _ServiceListState extends State<ServiceList> {
  int _selectedService;
  List<Service> _services = [];
  bool _isRegistredToProvider = false;
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
      final response =
          await ServiceService().fetchServicesByAdmin(prefs.getString('token'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        _services = Service.listFromJson(jsonData);
        _isRegistredToProvider = true;
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

  void _deleteService(Service service) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: RichText(
              text: TextSpan(
            children: [
              WidgetSpan(child: Icon(Icons.delete)),
              TextSpan(
                  text: "  " + getTranslate(context, "DELETE") + " ?",
                  style: TextStyle(color: Colors.black, fontSize: 18)),
            ],
          )),
          content:
              new Text(getTranslate(context, "DELETE_SERVICE_CONFIRMATION")),
          actions: <Widget>[
            // ignore: deprecated_member_use
            new FlatButton(
              child: new Text(getTranslate(context, "NO")),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            // ignore: deprecated_member_use
            new FlatButton(
              child: new Text(getTranslate(context, "YES")),
              onPressed: () async {
                try {
                  Navigator.of(dialogContext).pop();
                  var prefs = await SharedPreferences.getInstance();
                  var res = await ServiceService()
                      .deleteService(prefs.getString('token'), service.id);
                  assert(res.statusCode == 204);
                  _fetchServices();
                  final snackBar = SnackBar(
                    content: Text(getTranslate(context, "SUCCESS_DELETE")),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } catch (e) {
                  final snackBar = SnackBar(
                    content: Text(getTranslate(context, "FAIL_DELETE")),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            ),
          ],
        );
      },
    );
  }

  _showPopupMenu(Service service) => PopupMenuButton(onSelected: (value) {
        if (value == "UPDATE") {
          _selectedService = service.id;
          changePage(1);
        }
        if (value == "HANDLE") {
          _selectedService = service.id;
          changePage(2);
        }
        if (value == "STATISTICS") {
          _selectedService = service.id;
          changePage(3);
        }
        if (value == "DELETE") {
          _deleteService(service);
        }
      }, itemBuilder: (BuildContext context) {
        return {"UPDATE", "HANDLE", "STATISTICS", "DELETE"}
            .map((String choice) {
          return PopupMenuItem(
            value: choice,
            child: Row(
              children: [
                Icon(
                  choice == "UPDATE"
                      ? Icons.create_rounded
                      : choice == "HANDLE"
                          ? Icons.settings
                          : choice == "STATISTICS"
                              ? Icons.bar_chart
                              : Icons.delete,
                ),
                Text("   " + getTranslate(context, choice)),
              ],
            ),
          );
        }).toList();
      });

  Widget serviceCard(Service service) {
    return GestureDetector(
      child: Card(
          color: Colors.orange[50],
          child: ListTile(
            dense: true,
            title: Text(
              service.title,
            ),
            subtitle: Text(service.description),
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
            trailing: _showPopupMenu(service),
          )),
    );
  }

  void changePage(int index) {
    if (index == 0) _fetchServices();
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
              title: Text(getTranslate(context, "E-SAFFS")),
              actions: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: !_isRegistredToProvider
                      ? null
                      : () {
                          _selectedService = null;
                          changePage(1);
                        },
                )
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
        : _currentIndex == 1
            ? AddUpdateService(_selectedService, changePage)
            : _currentIndex == 2
                ? HandleService(_selectedService, changePage)
                : Indicators(_selectedService, changePage);
  }
}
