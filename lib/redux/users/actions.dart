import 'dart:convert';
import 'dart:io';
import 'package:issaf/errorHandler.dart';
import 'package:issaf/models/user.dart';
import 'package:issaf/redux/store.dart';
import 'package:issaf/redux/users/state.dart';
import 'package:issaf/services/provideService.dart';
import 'package:issaf/services/userService.dart';
import 'package:redux/redux.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class SetUserStateAction {
  final UserState userState;
  SetUserStateAction(this.userState);
}

//check token is valid
Future<void> checkLoggedInUserAction(Store<AppState> store) async {
  store.dispatch(SetUserStateAction(UserState(isCheckingLogin: true)));
  try {
    var prefs = await SharedPreferences.getInstance();
    final response = await UserService().checkToken(prefs.getString('token'));
    final jsonData = json.decode(response.body);
    assert(jsonData["id"] != null);
    store.dispatch(
      SetUserStateAction(
        UserState(
          isCheckingLogin: false,
          isLoggedIn: true,
          user: User.fromJson(jsonData),
        ),
      ),
    );
  } catch (error) {
    store.dispatch(SetUserStateAction(
        UserState(isCheckingLogin: false, isLoggedIn: false)));
  }
}

//sign in user
Future<void> signInUserAction(Store<AppState> store, String username,
    String password, dynamic context) async {
  store.dispatch(SetUserStateAction(UserState(isLoading: true)));
  try {
    var prefs = await SharedPreferences.getInstance();
    final response = await UserService().signIn(username, password);
    final jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      await prefs.setString('token', jsonData["data"]["api_token"]);
      store.dispatch(
        SetUserStateAction(
          UserState(
            isLoggedIn: true,
            isLoading: false,
            isError: false,
            errorText: '',
            user: User.fromJson(jsonData["data"]),
          ),
        ),
      );
    } else {
      var error = jsonData["errors"] as Map<String, dynamic>;
      store.dispatch(
        SetUserStateAction(
          UserState(
            isLoggedIn: false,
            isError: true,
            isLoading: false,
            errorText: errorHandler(error.values.first[0], context),
          ),
        ),
      );
    }
  } catch (error) {
    store.dispatch(SetUserStateAction(UserState(
        isLoggedIn: false,
        isError: true,
        isLoading: false,
        errorText: errorHandler("ERROR_SERVER", context))));
  }
}

//sign up / register user
Future<void> signUpUserAction(
    Store<AppState> store,
    String username,
    String password,
    String name,
    String email,
    String mobile,
    String sexe,
    String role,
    dynamic context) async {
  store.dispatch(SetUserStateAction(UserState(isLoading: true)));
  try {
    var prefs = await SharedPreferences.getInstance();
    final response = await UserService()
        .signUp(username, password, name, email, mobile, sexe, role);
    final jsonData = json.decode(response.body);
    if (response.statusCode == 201) {
      await prefs.setString('token', jsonData["data"]["api_token"]);
      store.dispatch(
        SetUserStateAction(
          UserState(
            isLoggedIn: true,
            isError: false,
            errorText: '',
            isLoading: false,
            user: User.fromJson(jsonData["data"]),
          ),
        ),
      );
    } else {
      var error = jsonData["errors"] as Map<String, dynamic>;

      store.dispatch(
        SetUserStateAction(
          UserState(
            isLoggedIn: false,
            isError: true,
            isLoading: false,
            errorText: errorHandler(error.values.first[0], context),
          ),
        ),
      );
    }
  } catch (error) {
    store.dispatch(SetUserStateAction(UserState(
        isLoggedIn: false,
        isError: true,
        isLoading: false,
        errorText: errorHandler("ERROR_SERVER", context))));
  }
}

//sign up provider
Future<void> signUpProviderAction(
    Store<AppState> store,
    String username,
    String password,
    String name,
    String email,
    String mobile,
    String sexe,
    String role,
    String title,
    String description,
    String mobileF,
    String emailF,
    String address,
    String url,
    File image,
    dynamic context) async {
  store.dispatch(SetUserStateAction(UserState(isLoading: true)));
  try {
    var prefs = await SharedPreferences.getInstance();
    final response = await UserService()
        .signUp(username, password, name, email, mobile, sexe, role);
    final jsonData = json.decode(response.body);
    if (response.statusCode == 201) {
      await prefs.setString('token', jsonData["data"]["api_token"]);
      await ProviderService().addProvider(jsonData["data"]["api_token"], title,
          description, address, emailF, mobileF, url, image);
      store.dispatch(
        SetUserStateAction(
          UserState(
            isLoggedIn: true,
            isError: false,
            errorText: '',
            isLoading: false,
            user: User.fromJson(jsonData["data"]),
          ),
        ),
      );
    } else {
      var error = jsonData["errors"] as Map<String, dynamic>;
      store.dispatch(
        SetUserStateAction(
          UserState(
            isLoggedIn: false,
            isError: true,
            isLoading: false,
            errorText: errorHandler(error.values.first[0], context),
          ),
        ),
      );
    }
  } catch (error) {
    store.dispatch(SetUserStateAction(UserState(
        isLoggedIn: false,
        isError: true,
        isLoading: false,
        errorText: errorHandler("ERROR_SERVER", context))));
  }
}

//logout user
Future<void> logoutUserAction(Store<AppState> store) async {
  var prefs = await SharedPreferences.getInstance();
  await UserService().logout(prefs.getString('token'));
  await prefs.setString('token', null);
  store.dispatch(
    SetUserStateAction(
      UserState(
        isLoggedIn: false,
        user: null,
      ),
    ),
  );
}
