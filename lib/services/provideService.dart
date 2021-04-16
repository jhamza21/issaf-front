import 'dart:io';

import 'package:http/http.dart' as http;

class ProviderService {
//fetch all providers
  Future<http.Response> fetchProviders(String token) async {
    var url = "http://10.0.2.2:8000/api/providers?api_token=" + token;
    return await http.get(url);
  }

  //fetch connected user provider
  Future<http.Response> fetchProviderUser(String token) async {
    var url = "http://10.0.2.2:8000/api/getUserProvider?api_token=" + token;
    return await http.get(url);
  }

  //add or update provider
  Future<http.StreamedResponse> addUpdateProvider(
      String token,
      int id,
      String title,
      String description,
      String address,
      String email,
      String mobile,
      String siteWeb,
      File image) async {
    var url;
    if (id != null)
      url = "http://10.0.2.2:8000/api/providers/" +
          id.toString() +
          "?api_token=" +
          token;
    else
      url = "http://10.0.2.2:8000/api/providers?api_token=" + token;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    if (image != null)
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
