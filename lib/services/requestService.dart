import 'package:http/http.dart' as http;
import 'package:issaf/constants.dart';

class RequestService {
//fetch received requests
  Future<http.Response> fetchReceivedRequests(String token) async {
    var url = URL_BACKEND + "getReceivedRequests?api_token=" + token;
    return await http.get(url);
  }

  //fetch sended requests
  Future<http.Response> fetchSendedRequests(String token) async {
    var url = URL_BACKEND + "getSendedRequests?api_token=" + token;
    return await http.get(url);
  }

  //refuse request
  Future<http.Response> refuseRequest(String token, int id) async {
    var url =
        URL_BACKEND + "refuseRequest/" + id.toString() + "?api_token=" + token;
    return await http.put(url);
  }

  //accept request
  Future<http.Response> acceptRequest(String token, int id) async {
    var url =
        URL_BACKEND + "acceptRequest/" + id.toString() + "?api_token=" + token;
    return await http.put(url);
  }

  //delete request
  Future<http.Response> deleteRequest(String token, int id) async {
    var url = URL_BACKEND + "requests/" + id.toString() + "?api_token=" + token;
    return await http.delete(url);
  }
}
