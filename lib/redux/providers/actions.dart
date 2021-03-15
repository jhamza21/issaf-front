import 'dart:convert';
import 'package:issaf/errorHandler.dart';
import 'package:issaf/models/provider.dart';
import 'package:issaf/redux/providers/state.dart';
import 'package:issaf/redux/store.dart';
import 'package:issaf/services/provideService.dart';
import 'package:redux/redux.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class SetProviderStateAction {
  final ProviderState providerState;
  SetProviderStateAction(this.providerState);
}

//check token is valid
Future<void> fetchProvidersAction(
    Store<AppState> store, dynamic context) async {
  store.dispatch(SetProviderStateAction(ProviderState(isLoading: true)));
  try {
    var prefs = await SharedPreferences.getInstance();
    final response =
        await ProviderService().fetchProviders(prefs.getString('token'));

    assert(response.statusCode == 200);
    final jsonData = json.decode(response.body);
    store.dispatch(
      SetProviderStateAction(
        ProviderState(
          isLoading: false,
          providers: Provider.listFromJson(jsonData),
        ),
      ),
    );
  } catch (error) {
    store.dispatch(SetProviderStateAction(ProviderState(
        isError: false, errorText: errorHandler("ERROR_SERVER", context))));
  }
}
