import 'package:http/http.dart' as http;

class ProviderService {
//login
  Future<http.Response> fetchProviders(String token) async {
    var url = "http://10.0.2.2:8000/api/providers?api_token=" + token;
    return await http.get(url);
  }
}
