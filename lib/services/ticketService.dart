import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:issaf/constants.dart';

class TicketService {
  //fetch tickets
  Future<http.Response> fetchTickets(String token) async {
    var url = URL_BACKEND + "tickets/?api_token=" + token;
    return await http.get(url);
  }

  //fetch available tickets by Date
  Future<http.Response> fetchAvailableTicketsByDat(
      String token, String date, String serviceId) async {
    var url = URL_BACKEND +
        "tickets/" +
        date +
        "/" +
        serviceId +
        "?api_token=" +
        token;
    return await http.get(url);
  }

  //add ticket
  Future<http.Response> addTicket(
      String token, String date, String time, int serviceId) async {
    var url = URL_BACKEND + "tickets?api_token=" + token;
    return await http.post(url,
        headers: {
          "content-type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode({
          "date": date,
          "time": time,
          "service_id": serviceId,
        }));
  }

  //delete ticket
  Future<http.Response> deleteTicket(String token, int id) async {
    var url = URL_BACKEND + "tickets/" + id.toString() + "?api_token=" + token;
    return await http.delete(url);
  }
}
