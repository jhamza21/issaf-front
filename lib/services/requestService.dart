import 'package:http/http.dart' as http;

class RequestService {
//fetch received requests
  Future<http.Response> fetchReceivedRequests(String token) async {
    var url = "http://10.0.2.2:8000/api/requests/received?api_token=" + token;
    return await http.get(url);
  }

  //fetch received requests
  Future<http.Response> fetchSendedRequests(String token) async {
    var url = "http://10.0.2.2:8000/api/requests/sended?api_token=" + token;
    return await http.get(url);
  }
}
