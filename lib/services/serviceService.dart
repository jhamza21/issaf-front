import 'dart:io';

import 'package:http/http.dart' as http;

class ServiceService {
//fetch all services
  Future<http.Response> fetchServices(String token, int idProvider) async {
    var url = "http://10.0.2.2:8000/api/providers/" +
        idProvider.toString() +
        "?api_token=" +
        token;
    return await http.get(url);
  }

  //get service by id
  Future<http.Response> getServiceById(String token, int id) async {
    var url = "http://10.0.2.2:8000/api/getServiceById/" +
        id.toString() +
        "?api_token=" +
        token;
    return await http.get(url);
  }

//delete service
  Future<http.Response> deleteService(String token, int id) async {
    var url = "http://10.0.2.2:8000/api/services/" +
        id.toString() +
        "?api_token=" +
        token;
    return await http.delete(url);
  }

//add or update service data
  Future<http.StreamedResponse> addUpdateService(
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
    var url;
    if (id == null)
      url = "http://10.0.2.2:8000/api/services?api_token=" + token;
    else
      url = "http://10.0.2.2:8000/api/services/" +
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
}
