import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService {
//login
  Future<http.Response> signIn(String userName, String password) async {
    var url = "http://10.0.2.2:8000/api/login";
    return await http.post(url,
        headers: {
          "content-type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode({
          "email": userName,
          "password": password,
        }));
  }

//sign up
  Future<http.Response> signUp(String userName, String password) async {
    var url = "http://10.0.2.2:8000/api/register";
    return await http.post(url,
        headers: {
          "content-type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode({
          "name": "x",
          "email": userName,
          "password": password,
          "password_confirmation": password
        }));
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
