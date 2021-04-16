import 'package:http/http.dart' as http;

class RequestService {
//fetch received requests
  Future<http.Response> fetchReceivedRequests(String token) async {
    var url = "http://10.0.2.2:8000/api/requests/received?api_token=" + token;
    return await http.get(url);
  }

  //fetch sended requests
  Future<http.Response> fetchSendedRequests(String token) async {
    var url = "http://10.0.2.2:8000/api/requests/sended?api_token=" + token;
    return await http.get(url);
  }

  //delete request
  Future<http.Response> deleteRequest(String token, int id) async {
    var url = "http://10.0.2.2:8000/api/requests/" +
        id.toString() +
        "?api_token=" +
        token;
    return await http.delete(url);
  }

  //refuse request
  Future<http.Response> refuseRequest(String token, int id) async {
    var url = "http://10.0.2.2:8000/api/requests/" +
        id.toString() +
        "?api_token=" +
        token;
    return await http.delete(url);
  }

  //accept request
  Future<http.Response> acceptRequest(String token, int id) async {
    var url = "http://10.0.2.2:8000/api/requests/" +
        id.toString() +
        "?api_token=" +
        token;
    return await http.delete(url);
  }
}
