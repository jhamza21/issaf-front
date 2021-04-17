import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:issaf/constants.dart';

class UserService {
//login
  Future<http.Response> getUserByUsername(String token, String username) async {
    var url =
        URL_BACKEND + "getUserByUsername/" + username + "?api_token=" + token;
    return await http.get(url);
  }

//get user by id
  Future<http.Response> getUserById(String token, int id) async {
    var url =
        URL_BACKEND + "getUserById/" + id.toString() + "?api_token=" + token;
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
      String email, String mobile, String sexe, String role) async {
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
          "sexe": sexe,
          "role": role
        }));
  }

//update user data
  Future<http.Response> updateUser(
      String token,
      String username,
      String password,
      String name,
      String sexe,
      String role,
      String email,
      String mobile) async {
    var url = URL_BACKEND + "updateAccount?api_token=" + token;
    Map<String, dynamic> data = {};
    if (username != null) data["username"] = username;
    if (password != null) data["password"] = password;
    if (name != null) data["name"] = name;
    if (sexe != null) data["sexe"] = sexe;
    if (role != null) data["role"] = role;
    if (email != null) data["email"] = email;
    if (mobile != null) data["mobile"] = mobile;

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
