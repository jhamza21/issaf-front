import 'dart:convert';
import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/provider.dart';
import 'package:issaf/models/service.dart';
import 'package:issaf/services/serviceService.dart';
import 'package:issaf/views/providers/addUpdateService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceList extends StatefulWidget {
  final Provider provider;
  ServiceList(this.provider);

  @override
  _ServiceListState createState() => _ServiceListState();
}

@override
class _ServiceListState extends State<ServiceList> {
  Service _selectedService;
  List<Service> _services = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  var _tapPosition;

  @override
  void initState() {
    super.initState();
    _fetchServices();
    _tapPosition = Offset(0.0, 0.0);
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
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

  void _deleteService(Service service) {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(getTranslate(context, "DELETE") + "?"),
          content: new Text(getTranslate(context, "DELETE_CONFIRMATION") +
              service.title +
              " ?"),
          actions: <Widget>[
            // ignore: deprecated_member_use
            new FlatButton(
              child: new Text(getTranslate(context, "NO")),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // ignore: deprecated_member_use
            new FlatButton(
              child: new Text(getTranslate(context, "YES")),
              onPressed: () async {
                try {
                  var prefs = await SharedPreferences.getInstance();
                  var res = await ServiceService()
                      .deleteService(prefs.getString('token'), service.id);
                  assert(res.statusCode == 204);
                  Navigator.of(context).pop();
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

  _showPopupMenu(Service service) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    await showMenu(
        context: context,
        position: RelativeRect.fromRect(
            _tapPosition & Size(40, 40), Offset.zero & overlay.size),
        items: <PopupMenuEntry>[
          PopupMenuItem(
            // ignore: deprecated_member_use
            child: FlatButton.icon(
              icon: Icon(
                Icons.create_rounded,
              ),
              label: Text(getTranslate(context, "UPDATE")),
              onPressed: () {
                Navigator.of(context).pop();
                _selectedService = service;
                changePage(1);
              },
            ),
          ),
          PopupMenuItem(
            // ignore: deprecated_member_use
            child: FlatButton.icon(
              icon: Icon(
                Icons.delete,
              ),
              label: Text(getTranslate(context, "DELETE")),
              onPressed: () {
                _deleteService(service);
              },
            ),
          ),
          PopupMenuItem(
            // ignore: deprecated_member_use
            child: FlatButton.icon(
              icon: Icon(
                Icons.info,
              ),
              label: Text(getTranslate(context, "DETAILS")),
              onPressed: () {
                Navigator.of(context).pop();
                _selectedService = service;
                changePage(1);
              },
            ),
          ),
        ]);
  }

  Widget serviceCard(Service service) {
    return GestureDetector(
      onTapDown: _storePosition,
      onLongPress: () => _showPopupMenu(service),
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
          trailing: Icon(
            Icons.circle,
            size: 15,
            color: service.userId == null ? Colors.red : Colors.green,
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
              title: Text(getTranslate(context, "E-SAFFS")),
              actions: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (widget.provider == null) {
                      final snackBar = SnackBar(
                        content: Text(
                            getTranslate(context, "EVENT_REQUIRE_PROVIDER")),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      _selectedService = null;
                      changePage(1);
                    }
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
        : AddUpdateService(
            widget.provider, _selectedService, changePage, _fetchServices);
  }
}
