import 'dart:io';

import 'package:http/http.dart' as http;

class ServiceService {
//fetch all providers
  Future<http.Response> fetchServices(String token, int idProvider) async {
    var url = "http://10.0.2.2:8000/api/providers/" +
        idProvider.toString() +
        "?api_token=" +
        token;
    return await http.get(url);
  }

  //fetch connected user provider
  Future<http.Response> fetchProvider(String token) async {
    var url = "http://10.0.2.2:8000/api/getUserProvider?api_token=" + token;
    return await http.get(url);
  }

//update provider data
  Future<http.StreamedResponse> updateProvider(
      String token,
      int id,
      String title,
      String description,
      String address,
      String email,
      String mobile,
      String siteWeb,
      File image,
      String oldPassword) async {
    var url = "http://10.0.2.2:8000/api/providers/" +
        id.toString() +
        "?api_token=" +
        token;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    request.fields['oldPassword'] = oldPassword;

    if (image != null)
      request.files.add(await http.MultipartFile.fromPath('img', image.path));
    if (title != null) request.fields['title'] = title;
    if (description != null) request.fields['description'] = description;
    if (address != null) request.fields['address'] = address;
    if (email != null) request.fields['email'] = email;
    if (mobile != null) request.fields['mobile'] = mobile;
    if (siteWeb != null) request.fields['url'] = siteWeb;
    return await request.send();
  }

  //fetch all providers
  Future<http.StreamedResponse> addProvider(
      String token,
      String title,
      String description,
      String address,
      String email,
      String mobile,
      String siteWeb,
      File image) async {
    var url = "http://10.0.2.2:8000/api/providers?api_token=" + token;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('img', image.path));
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['address'] = address;
    request.fields['email'] = email;
    request.fields['mobile'] = mobile;
    request.fields['url'] = siteWeb;
    return await request.send();
  }
}
