import 'dart:convert';
import 'dart:ui';
import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/provider.dart';
import 'package:issaf/services/provideService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProvidersList extends StatefulWidget {
  final String title;
  ProvidersList(this.title);
  @override
  _ProvidersListState createState() => _ProvidersListState();
}

@override
class _ProvidersListState extends State<ProvidersList> {
  Widget cusSearchBar;
  Icon cusIcon = Icon(Icons.search);
  List<String> _favoriteProviders = [];
  List<Provider> _orderedProviders = [];
  List<Provider> _providers = [];
  String _searchText;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    cusSearchBar = Text(widget.title);
    _fetchFavorites();
    _fetchProviders();
  }

  void _fetchFavorites() async {
    var prefs = await SharedPreferences.getInstance();
    _favoriteProviders = prefs.getStringList("favorite") ?? [];
  }

  void _fetchProviders() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      final response =
          await ProviderService().fetchProviders(prefs.getString('token'));

      assert(response.statusCode == 200);
      final jsonData = json.decode(response.body);
      _providers = Provider.listFromJson(jsonData);

      sortedProviders();
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _orderedProviders.add(new Provider(
            title: "STEG",
            description: "Société tunisienne d'électricité et du gaz",
            email: "j.hamza@hotmail.fr",
            id: 0,
            url: "www.google.fr",
            mobile: "+21655589087,"));
        _isLoading = false;
        _orderedProviders.add(new Provider(
            title: "STEG",
            description: "Société tunisienne d'électricité et du gaz",
            email: "j.hamza@hotmail.fr",
            id: 0,
            url: "www.google.fr",
            mobile: "+21655589087,"));
        _isLoading = false;
      });
    }
  }

  sortedProviders() {
    _orderedProviders = [];
    _providers.forEach((element) {
      if (_favoriteProviders.contains(element.id.toString()))
        _orderedProviders.insert(0, element);
      else
        _orderedProviders.add(element);
    });
  }

  Card providerCard(Provider provider) {
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
          backgroundImage: null, // NetworkImage(
          //     "http://10.0.2.2:8000/api/providerImg/" + provider.image),
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
                            provider.title,
                            provider.description,
                            Column(
                              children: [
                                provider.email != null
                                    ? Row(
                                        children: [
                                          Icon(Icons.email),
                                          Text(" : " + provider.email)
                                        ],
                                      )
                                    : SizedBox.shrink(),
                                provider.mobile != null
                                    ? Row(
                                        children: [
                                          Icon(Icons.phone),
                                          Text(" : " + provider.mobile)
                                        ],
                                      )
                                    : SizedBox.shrink(),
                                provider.url != null
                                    ? Row(
                                        children: [
                                          Icon(Icons.web),
                                          Text(" : " + provider.url)
                                        ],
                                      )
                                    : SizedBox.shrink(),
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
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              icon: Icon(
                _favoriteProviders.contains(provider.id.toString())
                    ? Icons.star
                    : Icons.star_border,
                size: 17,
                color: Colors.deepOrange,
              ),
              onPressed: () async {
                var prefs = await SharedPreferences.getInstance();
                if (_favoriteProviders.contains(provider.id.toString())) {
                  //Remove favorite provider
                  setState(() {
                    _favoriteProviders.remove(provider.id.toString());
                    sortedProviders();
                  });
                  prefs.setStringList("favorite", _favoriteProviders);
                } else {
                  //Add favorite provider
                  var prefs = await SharedPreferences.getInstance();
                  setState(() {
                    _favoriteProviders.add(provider.id.toString());
                    sortedProviders();
                  });
                  prefs.setStringList("favorite", _favoriteProviders);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  // Widget providerCard(Provider provider) {
  //   return new Container(
  //       height: 120.0,
  //       margin: const EdgeInsets.symmetric(
  //         vertical: 10.0,
  //       ),
  //       child: new Stack(
  //         children: <Widget>[
  //           //container
  //           new Container(
  //             margin: new EdgeInsets.only(left: 46.0),
  //             decoration: new BoxDecoration(
  //               color: Colors.orange[50],
  //               shape: BoxShape.rectangle,
  //               borderRadius: new BorderRadius.circular(8.0),
  //               boxShadow: <BoxShadow>[
  //                 new BoxShadow(
  //                   color: Colors.black12,
  //                   blurRadius: 2.0,
  //                   offset: new Offset(0.0, 10.0),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           //image
  //           new Container(
  //             margin: new EdgeInsets.symmetric(vertical: 16.0),
  //             alignment: FractionalOffset.centerLeft,
  //             child: new Image(
  //               image: new AssetImage("assets/images/steg.png"),
  //               height: 92.0,
  //               width: 92.0,
  //             ),
  //           ),
  //           //arrow
  //           new Container(
  //             margin: new EdgeInsets.symmetric(vertical: 16.0),
  //             alignment: FractionalOffset.centerRight,
  //             child: new Icon(
  //               Icons.arrow_forward_ios,
  //               color: Colors.grey[700],
  //             ),
  //           ),
  //           //dots
  //           new Container(
  //             margin: new EdgeInsets.symmetric(vertical: 16.0),
  //             alignment: FractionalOffset.topRight,
  //             child: new Icon(
  //               Icons.threesixty_rounded,
  //               color: Colors.grey[700],
  //             ),
  //           ),
  //         ],
  //       ));
  // }

  Widget customDialog(String title, String description, Widget content) {
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
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(45)),
                  child: Image.asset("assets/images/steg.png")),
            ),
          ) // top part
        ],
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
            : _orderedProviders.length == 0
                ? Center(
                    child: Text(getTranslate(context, "NO_RESULT_FOUND")),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: _orderedProviders.length,
                    itemBuilder: (context, index) {
                      if (_searchText != null) {
                        //show only searched providers
                        if (_orderedProviders[index]
                            .title
                            .toLowerCase()
                            .contains(_searchText.toLowerCase()))
                          return providerCard(_orderedProviders[index]);
                        else
                          return SizedBox.shrink();
                      } else
                        return providerCard(_orderedProviders[index]);
                    },
                  ));
  }
}
