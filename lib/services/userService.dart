import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:issaf/constants.dart';
import 'package:issaf/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  //get all users

  Future<List<User>> getUserSuggestions(String text) async {
    try {
      var prefs = await SharedPreferences.getInstance();

      if (text != "") {
        var url = URL_BACKEND +
            "users/" +
            text +
            "?api_token=" +
            prefs.getString('token');
        var res = await http.get(url);
        return User.listFromJson(json.decode(res.body));
      } else
        return [];
    } catch (e) {
      return [];
    }
  }

//get user by username
  Future<http.Response> getUserByEmail(String email) async {
    var url = URL_BACKEND + "getUserByEmail/" + email;
    return await http.get(url);
  }

//login
  Future<http.Response> signIn(String username, String password) async {
    var url = URL_BACKEND + "login";
    return await http.post(url,
        headers: {
          "content-type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode({"username": username, "password": password}));
  }

//sign up
  Future<http.Response> signUp(String username, String password, String name,
      String email, String mobile, String region, String messaginToken) async {
    var url = URL_BACKEND + "register";
    return await http.post(url,
        headers: {
          "content-type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode({
          "username": username,
          "password": password,
          "password_confirmation": password,
          "name": name,
          "email": email,
          "mobile": mobile,
          "region": region,
          "messaging_token": messaginToken
        }));
  }

//update user data
  Future<http.Response> updateUser(
    String token,
    String username,
    String password,
    String name,
    String email,
    String mobile,
    String region,
  ) async {
    var url = URL_BACKEND + "updateAccount?api_token=" + token;
    Map<String, dynamic> data = {};
    if (username != null) data["username"] = username;
    if (password != null) data["password"] = password;
    if (name != null) data["name"] = name;
    if (email != null) data["email"] = email;
    if (mobile != null) data["mobile"] = mobile;
    if (region != null) data["region"] = region;

    return await http.put(url,
        headers: {
          "content-type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode(data));
  }

//check if user token is valid
  Future<http.Response> checkToken(String token) async {
    var url = URL_BACKEND + "tokenIsValid?api_token=" + token;
    return await http.post(url);
  }

  //logout user
  Future<http.Response> logout(String token) async {
    var url = URL_BACKEND + "logout?api_token=" + token;
    return await http.post(url);
  }
}
