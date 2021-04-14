import 'dart:convert';
import 'dart:ui';
import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/provider.dart';
import 'package:issaf/services/provideService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

@override
class _NotificationsState extends State<Notifications> {
  Widget cusSearchBar;
  Icon cusIcon = Icon(Icons.search);
  List<Provider> _notifications = [];
  String _searchText;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  void _fetchServices() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      final response =
          await ProviderService().fetchProviders(prefs.getString('token'));

      assert(response.statusCode == 200);
      final jsonData = json.decode(response.body);
      _notifications = Provider.listFromJson(jsonData);
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Card notificationCard(Provider provider) {
    return Card(
      color: Colors.orange[50],
      child: ListTile(
        dense: true,
        title: Text(
          provider.title,
        ),
        subtitle: Text(provider.description),
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          radius: 30.0,
          backgroundImage: NetworkImage(
              "http://10.0.2.2:8000/api/providerImg/" + provider.image),
        ),
        trailing: IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          icon: Icon(
            Icons.delete,
            size: 17,
            color: Colors.deepOrange,
          ),
          onPressed: () async {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          title: cusSearchBar,
          actions: [
            IconButton(
                icon: cusIcon,
                onPressed: () {
                  setState(() {
                    if (cusIcon.icon == Icons.search) {
                      cusIcon = Icon(Icons.cancel);
                      cusSearchBar = TextFormField(
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: getTranslate(context, "SEARCH_HERE")),
                        textInputAction: TextInputAction.go,
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                        onChanged: (val) {
                          setState(() {
                            _searchText = val;
                          });
                        },
                      );
                    } else {
                      cusIcon = Icon(Icons.search);
                      cusSearchBar = Text(getTranslate(context, "PROVIDERS"));
                      _searchText = null;
                    }
                  });
                })
          ],
        ),
        body: _isLoading
            ? Center(child: circularProgressIndicator)
            : _notifications.length == 0
                ? Center(
                    child: Text(getTranslate(context, "NO_RESULT_FOUND")),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      if (_searchText != null) {
                        //show only searched providers
                        if (_notifications[index]
                            .title
                            .toLowerCase()
                            .contains(_searchText.toLowerCase()))
                          return notificationCard(_notifications[index]);
                        else
                          return SizedBox.shrink();
                      } else
                        return notificationCard(_notifications[index]);
                    },
                  ));
  }
}
