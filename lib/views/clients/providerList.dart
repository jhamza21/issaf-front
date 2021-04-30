import 'dart:convert';
import 'dart:ui';
import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/provider.dart';
import 'package:issaf/redux/users/state.dart';
import 'package:issaf/services/provideService.dart';
import 'package:issaf/views/clients/serviceList.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProvidersList extends StatefulWidget {
  final String title;
  final UserState userState;
  ProvidersList(this.title, this.userState);
  @override
  _ProvidersListState createState() => _ProvidersListState();
}

@override
class _ProvidersListState extends State<ProvidersList> {
  Widget cusSearchBar;
  int _currentIndex = 0;
  Provider _selectedProvider;
  Icon cusIcon = Icon(Icons.search);
  List<String> _favoriteProvidersIds = [];
  List<Provider> _orderedProviders = [], _providers = [];
  String _searchText;
  bool _isLoading = true, _filterByRegion = true, _filterByType = false;
  String _region, _type = "HEALTH";

  void changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    cusSearchBar = Text(widget.title);
    _region = widget.userState.user.region;
    _fetchFavorites();
    _fetchProviders();
  }

  void _fetchFavorites() async {
    var prefs = await SharedPreferences.getInstance();
    _favoriteProvidersIds = prefs.getStringList("favorite") ?? [];
  }

  void _fetchProviders() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      final response =
          await ProviderService().fetchProviders(prefs.getString('token'));

      assert(response.statusCode == 200);
      final jsonData = json.decode(response.body);
      _providers = Provider.listFromJson(jsonData);

      filterProviders();
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  filterProviders() {
    setState(() {
      _isLoading = true;
    });
    _orderedProviders = [];
    List<Provider> _filtredByRegion = [], filtredByType = [];
    //filter by region
    if (_filterByRegion) {
      _providers.forEach((element) {
        if (element.region == _region) _filtredByRegion.add(element);
      });
    } else
      _filtredByRegion = _providers;
    //filter by type
    if (_filterByType) {
      _filtredByRegion.forEach((element) {
        if (element.type == _type) filtredByType.add(element);
      });
    } else
      filtredByType = _filtredByRegion;
    //sort providers
    filtredByType.forEach((element) {
      if (_favoriteProvidersIds.contains(element.id.toString()))
        _orderedProviders.insert(0, element);
      else
        _orderedProviders.add(element);
    });
    setState(() {
      _isLoading = false;
    });
  }

  void _selectProvider(Provider provider) {
    _selectedProvider = provider;
    changePage(1);
  }

  void _showProviderInfo(Provider provider) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return customDialog(
              provider.title,
              provider.description,
              provider.image != null ? "providerImg/" + provider.image : null,
              Column(
                children: [
                  provider.email != ''
                      ? Row(
                          children: [
                            Icon(Icons.email),
                            Expanded(child: Text(" : " + provider.email))
                          ],
                        )
                      : SizedBox.shrink(),
                  provider.mobile != ''
                      ? Row(
                          children: [
                            Icon(Icons.phone),
                            Text(" : " +
                                provider.mobile.split("/")[1] +
                                provider.mobile.split("/")[2])
                          ],
                        )
                      : SizedBox.shrink(),
                  provider.url != ''
                      ? Row(
                          children: [
                            Icon(Icons.web),
                            Expanded(child: Text(" : " + provider.url))
                          ],
                        )
                      : SizedBox.shrink(),
                ],
              ));
        });
  }

  void _likeOrUnlikeProvider(Provider provider) async {
    var prefs = await SharedPreferences.getInstance();
    if (_favoriteProvidersIds.contains(provider.id.toString())) {
      //Remove favorite provider
      setState(() {
        _favoriteProvidersIds.remove(provider.id.toString());
        filterProviders();
      });
      prefs.setStringList("favorite", _favoriteProvidersIds);
    } else {
      //Add favorite provider
      var prefs = await SharedPreferences.getInstance();
      setState(() {
        _favoriteProvidersIds.add(provider.id.toString());
        filterProviders();
      });
      prefs.setStringList("favorite", _favoriteProvidersIds);
    }
  }

  Widget providerCard(Provider provider) {
    return GestureDetector(
      onTap: () => _selectProvider(provider),
      child: Card(
        color: Colors.orange[50],
        child: ListTile(
          dense: true,
          title: Text(
            provider.title,
          ),
          subtitle: Text(provider.description),
          leading: CircleAvatar(
            backgroundColor: Colors.orange,
            child: provider.image == null
                ? Text(
                    provider.title[0].toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  )
                : SizedBox.shrink(),
            radius: 30.0,
            backgroundImage: provider.image != null
                ? NetworkImage(URL_BACKEND + "providerImg/" + provider.image)
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
                  _showProviderInfo(provider);
                },
              ),
              SizedBox(
                width: 8,
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Icon(
                  _favoriteProvidersIds.contains(provider.id.toString())
                      ? Icons.star
                      : Icons.star_border,
                  size: 17,
                  color: Colors.deepOrange,
                ),
                onPressed: () {
                  _likeOrUnlikeProvider(provider);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _providersList() {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          title: cusSearchBar,
          leading: IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () {
              showFilterDialog();
            },
          ),
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
                            _searchText = val.trim();
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

  showFilterDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(getTranslate(context, "FILTER_WITH")),
              content: Container(
                height: 100,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                            value: _filterByRegion,
                            onChanged: (v) {
                              setState(() {
                                _filterByRegion = v;
                              });
                            }),
                        Text(
                          getTranslate(context, "REGION") + " : ",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color:
                                  _filterByRegion ? Colors.black : Colors.grey),
                        ),
                        DropdownButton<String>(
                          value: _region,
                          underline: SizedBox.shrink(),
                          items: regions.map((region) {
                            return new DropdownMenuItem<String>(
                              value: region,
                              child: new Text(getTranslate(context, region)),
                            );
                          }).toList(),
                          onChanged: !_filterByRegion
                              ? null
                              : (x) {
                                  setState(() {
                                    _region = x;
                                  });
                                },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _filterByType,
                          onChanged: (v) {
                            setState(() {
                              _filterByType = v;
                            });
                          },
                        ),
                        Text(
                          getTranslate(context, "TYPE") + " : ",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color:
                                  _filterByType ? Colors.black : Colors.grey),
                        ),
                        DropdownButton<String>(
                          value: _type,
                          underline: SizedBox.shrink(),
                          items: providers.map((provider) {
                            return new DropdownMenuItem<String>(
                              value: provider,
                              child: new Text(getTranslate(context, provider)),
                            );
                          }).toList(),
                          onChanged: !_filterByType
                              ? null
                              : (x) {
                                  setState(() {
                                    _type = x;
                                  });
                                },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((value) => filterProviders());
  }

  @override
  Widget build(BuildContext context) {
    return _currentIndex == 0
        ? _providersList()
        : ServiceList(_selectedProvider, changePage);
  }
}
