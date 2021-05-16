import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:issaf/constants.dart';
import 'package:issaf/models/user.dart';

class ServiceService {
  //fetch services related to connected user(admin)
  Future<http.Response> fetchServicesByAdmin(String token) async {
    var url = URL_BACKEND + "getServicesByAdmin/?api_token=" + token;
    return await http.get(url);
  }

  //get service by id
  Future<http.Response> getServiceById(String token, int id) async {
    var url =
        URL_BACKEND + "getServiceById/" + id.toString() + "?api_token=" + token;
    return await http.get(url);
  }

  //get service related to operator
  Future<http.Response> getServiceByRespo(String token) async {
    var url = URL_BACKEND + "getServiceByRespo/?api_token=" + token;
    return await http.get(url, headers: {
      "Accept": "application/json",
      "Access-Control_Allow_Origin": "*"
    });
  }

//add or update service data
  Future<http.StreamedResponse> addUpdateService(
      String token,
      int id,
      List<User> users,
      String title,
      String description,
      String avgTimePerClient,
      String workStartTime,
      String workEndTime,
      List<String> openDays,
      List<String> hoolidays,
      List<String> breaks,
      File image) async {
    var url;
    if (id == null)
      url = URL_BACKEND + "services?api_token=" + token;
    else
      url = URL_BACKEND + "services/" + id.toString() + "?api_token=" + token;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    if (image != null)
      request.files.add(await http.MultipartFile.fromPath('img', image.path));

    //users
    for (int i = 0; i < users.length; i++)
      request.fields['users[' + i.toString() + ']'] = users[i].id.toString();

    if (title != null) request.fields['title'] = title;
    if (description != null) request.fields['description'] = description;

    if (avgTimePerClient != null)
      request.fields['avg_time_per_client'] = avgTimePerClient;
    if (workStartTime != null)
      request.fields['work_start_time'] = workStartTime;
    if (workEndTime != null) request.fields['work_end_time'] = workEndTime;
    //open days
    for (int i = 0; i < openDays.length; i++)
      request.fields['open_days[' + i.toString() + ']'] =
          openDays[i].toString();
    //hoolidays
    if (hoolidays.length > 0) {
      for (int i = 0; i < hoolidays.length; i++)
        request.fields['hoolidays[' + i.toString() + ']'] =
            hoolidays[i].toString();
    }
    //break times
    if (breaks.length > 0) {
      for (int i = 0; i < breaks.length; i++)
        request.fields['break_times[' + i.toString() + ']'] =
            breaks[i].toString();
    }
    return await request.send();
  }

  //update service counter
  Future<http.Response> updateCounter(String token, int id, int number) async {
    var url = URL_BACKEND + "services/" + id.toString() + "?api_token=" + token;
    return await http.put(url,
        headers: {
          "content-type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode({"counter": number}));
  }

  //delete service
  Future<http.Response> deleteService(String token, int id) async {
    var url = URL_BACKEND + "services/" + id.toString() + "?api_token=" + token;
    return await http.delete(url);
  }
}
