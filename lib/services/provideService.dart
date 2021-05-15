import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:issaf/constants.dart';

class ProviderService {
  //get a provider by id
  Future<http.Response> getProviderById(String token, int id) async {
    var url =
        URL_BACKEND + "providers/" + id.toString() + "?api_token=" + token;
    return await http.get(url);
  }

//fetch all providers
  Future<http.Response> fetchProviders(String token) async {
    var url = URL_BACKEND + "providers?api_token=" + token;
    return await http.get(
      url,
    );
  }

  //fetch connected user provider
  Future<http.Response> fetchProviderByUser(String token) async {
    var url = URL_BACKEND + "getProviderByUser?api_token=" + token;
    return await http.get(url);
  }

  //add or update provider
  Future<http.StreamedResponse> addUpdateProvider(
      String token,
      int id,
      String type,
      String title,
      String description,
      String email,
      String mobile,
      String siteWeb,
      String region,
      File image) async {
    var url;
    if (id != null)
      url = URL_BACKEND + "providers/" + id.toString() + "?api_token=" + token;
    else
      url = URL_BACKEND + "providers?api_token=" + token;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    if (image != null)
      request.files.add(await http.MultipartFile.fromPath('img', image.path));
    request.fields['type'] = type;
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['email'] = email;
    request.fields['mobile'] = mobile;
    request.fields['region'] = region;
    request.fields['url'] = siteWeb;
    return await request.send();
  }

  //delete provider
  Future<http.Response> deleteProvider(String token, int id) async {
    var url =
        URL_BACKEND + "providers/" + id.toString() + "?api_token=" + token;
    return await http.delete(url);
  }
}
