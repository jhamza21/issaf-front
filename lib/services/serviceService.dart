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
  Future<http.StreamedResponse> updateService(
      String token,
      int id,
      String title,
      String description,
      String avgTimePerClient,
      String counter,
      String workStartTime,
      String workEndTime,
      List<String> openDays,
      String status,
      File image) async {
    var url = "http://10.0.2.2:8000/api/services/" +
        id.toString() +
        "?api_token=" +
        token;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    if (image != null)
      request.files.add(await http.MultipartFile.fromPath('img', image.path));
    if (title != null) request.fields['title'] = title;
    if (description != null) request.fields['description'] = description;

    if (avgTimePerClient != null)
      request.fields['avg_time_per_client'] = avgTimePerClient;
    if (counter != null) request.fields['counter'] = counter;
    if (workStartTime != null)
      request.fields['work_start_time'] = workStartTime;
    if (workEndTime != null) request.fields['work_end_time'] = workEndTime;
    if (openDays != null) request.fields['open_days'] = openDays.toString();
    if (status != null) request.fields['status'] = status;
    return await request.send();
  }

  //fetch all providers
  Future<http.StreamedResponse> addService(
      String token,
      String title,
      String description,
      String avgTimePerClient,
      String counter,
      String workStartTime,
      String workEndTime,
      List<String> openDays,
      String status,
      File image) async {
    var url = "http://10.0.2.2:8000/api/services?api_token=" + token;
    var request = new http.MultipartRequest("POST", Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('img', image.path));
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['avg_time_per_client'] = avgTimePerClient;
    request.fields['counter'] = counter;
    request.fields['work_start_time'] = workStartTime;
    request.fields['work_end_time'] = workEndTime;
    request.fields['open_days'] = openDays.toString();
    request.fields['status'] = status;

    return await request.send();
  }
}
