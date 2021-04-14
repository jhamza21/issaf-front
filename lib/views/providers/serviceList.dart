import 'dart:convert';
import 'dart:ui';
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
      final jsonData = json.decode(response.body);
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

  Card serviceCard(Service service) {
    return Card(
      color: Colors.orange[50],
      child: ListTile(
        dense: true,
        title: Text(
          service.title,
        ),
        subtitle: Text(service.description),
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          radius: 30.0,
          backgroundImage: NetworkImage(
              "http://10.0.2.2:8000/api/serviceImg/" + service.image),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return customDialog(
                            service.title,
                            service.description,
                            service.image,
                            Column(
                              children: [
                                //TODO: add service card
                              ],
                            ));
                      });
                },
                icon: Icon(
                  Icons.info,
                  size: 17,
                )),
            SizedBox(
              width: 8,
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                size: 17,
                color: Colors.red,
              ),
              onPressed: () async {},
            ),
          ],
        ),
      ),
    );
  }

  Widget customDialog(
      String title, String description, String image, Widget content) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 20, top: 65, right: 20, bottom: 20),
            margin: EdgeInsets.only(top: 45),
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black,
                      offset: Offset(0, 10),
                      blurRadius: 10),
                ]),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                content,
              ],
            ),
          ), // bottom part
          Positioned(
            left: 20,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 45,
              child: CircleAvatar(
                backgroundColor: Colors.orange,
                radius: 40.0,
                backgroundImage: NetworkImage(
                    "http://10.0.2.2:8000/api/providerImg/" + image),
              ),
            ),
          ) // top part
        ],
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
              title: Text("Saff"),
              actions: [
                IconButton(
                    icon: Icon(Icons.add), onPressed: () => changePage(1))
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
        : AddUpdateService(widget.provider, changePage);
  }
}
