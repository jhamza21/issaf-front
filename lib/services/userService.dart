import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService {
//login
  Future<http.Response> signIn(String username, String password) async {
    var url = "http://10.0.2.2:8000/api/login";
    return await http.post(url,
        headers: {
          "content-type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode({
          "username": username,
          "password": password,
        }));
  }

//sign up
  Future<http.Response> signUp(String username, String password) async {
    var url = "http://10.0.2.2:8000/api/register";
    return await http.post(url,
        headers: {
          "content-type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode({
          "username": username,
          "password": password,
          "password_confirmation": password
        }));
  }

//update user data
  Future<http.Response> updateUser(Map data, String token) async {
    var url = "http://10.0.2.2:8000/api/updateAccount?api_token=" + token;
    return await http.put(url,
        headers: {
          "content-type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode(data));
  }

//check if user token is valid
  Future<http.Response> checkToken(String token) async {
    var url = "http://10.0.2.2:8000/api/tokenIsValid?api_token=" + token;
    return await http.post(url);
  }

  //logout user
  Future<http.Response> logout(String token) async {
    var url = "http://10.0.2.2:8000/api/logout?api_token=" + token;
    return await http.post(url);
  }
}
