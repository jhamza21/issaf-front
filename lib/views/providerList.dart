import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:issaf/constants.dart';
import 'package:issaf/models/provider.dart';
import 'package:issaf/redux/providers/actions.dart';
import 'package:issaf/redux/store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProvidersList extends StatefulWidget {
  final bool favorite;
  final String title;
  ProvidersList(this.favorite, this.title);
  @override
  _ProvidersListState createState() => _ProvidersListState();
}

@override
class _ProvidersListState extends State<ProvidersList> {
  Widget cusSearchBar;
  Icon cusIcon = Icon(Icons.search);
  List<String> favoriteProv = [];
  String searchText;

  @override
  void initState() {
    super.initState();
    cusSearchBar = Text(widget.title);
    _fetchFavorites();
    _fetchProviders();
  }

  void _fetchFavorites() async {
    var prefs = await SharedPreferences.getInstance();
    favoriteProv = prefs.getStringList("favorite") ?? [];
  }

  void _fetchProviders() {
    Redux.store.dispatch(fetchProvidersAction(Redux.store, context));
  }

  Card providerCard(Provider provider) {
    return Card(
      color: Colors.orange[100],
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(
              provider.name,
              style: TextStyle(fontSize: 24.0),
            ),
            subtitle: Text(provider.description),
            leading: CircleAvatar(
              backgroundColor: Colors.orange,
              radius: 30.0,
              backgroundImage: provider.name == "STEG"
                  ? AssetImage('assets/images/steg.png')
                  : AssetImage('assets/images/avatar.png'),
            ),
            trailing: !widget.favorite
                ? IconButton(
                    icon: Icon(
                      favoriteProv.contains(provider.id.toString())
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.red[600],
                    ),
                    onPressed: () async {
                      if (favoriteProv.contains(provider.id.toString())) {
                        //Remove favorite provider
                        var prefs = await SharedPreferences.getInstance();
                        setState(() {
                          favoriteProv.remove(provider.id.toString());
                        });
                        prefs.setStringList("favorite", favoriteProv);
                      } else {
                        //Add favorite provider
                        var prefs = await SharedPreferences.getInstance();
                        setState(() {
                          favoriteProv.add(provider.id.toString());
                        });
                        prefs.setStringList("favorite", favoriteProv);
                      }
                    },
                  )
                : SizedBox.shrink(),
          )),
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
                          searchText = val;
                        });
                      },
                    );
                  } else {
                    cusIcon = Icon(Icons.search);
                    cusSearchBar = Text(getTranslate(context, "PROVIDERS"));
                    searchText = null;
                  }
                });
              })
        ],
      ),
      body: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          if (state.providerState.isLoading)
            return Center(child: circularProgressIndicator);
          else if (state.providerState.providers.length == 0)
            return Center(
              child: Text(getTranslate(context, "NO_RESULT_FOUND")),
            );
          else
            return ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: state.providerState.providers.length,
              itemBuilder: (context, index) {
                if (widget.favorite) {
                  //show only favorite providers
                  if (favoriteProv.contains(
                      state.providerState.providers[index].id.toString())) {
                    if (searchText != null) {
                      //show only searched providers
                      if (state.providerState.providers[index].name
                          .toLowerCase()
                          .contains(searchText.toLowerCase()))
                        return providerCard(
                            state.providerState.providers[index]);
                      else
                        return SizedBox.shrink();
                    } else {
                      return providerCard(state.providerState.providers[index]);
                    }
                  } else {
                    return SizedBox.shrink();
                  }
                } else {
                  //show all providers
                  if (searchText != null) {
                    //show only searched providers
                    if (state.providerState.providers[index].name
                        .toLowerCase()
                        .contains(searchText.toLowerCase()))
                      return providerCard(state.providerState.providers[index]);
                    else
                      return SizedBox.shrink();
                  } else
                    return providerCard(state.providerState.providers[index]);
                }
              },
            );
        },
      ),
    );
  }
}
