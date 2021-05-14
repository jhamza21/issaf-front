import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:issaf/constants.dart';

class TicketService {
  //fetch tickets
  Future<http.Response> fetchTickets(String token) async {
    var url = URL_BACKEND + "tickets/?api_token=" + token;
    return await http.get(url);
  }

  //fetch tickets responsible
  Future<http.Response> fetchTicketsByServiceId(
      String token, int serviceId) async {
    var url = URL_BACKEND +
        "ticketsBySerice/" +
        serviceId.toString() +
        "?api_token=" +
        token;
    return await http.get(url);
  }

  //fetch available tickets by Date
  Future<http.Response> fetchAvailableTicketsByDat(
      String token, String date, int serviceId) async {
    var url = URL_BACKEND +
        "tickets/" +
        date +
        "/" +
        serviceId.toString() +
        "?api_token=" +
        token;
    return await http.get(url);
  }

  //add ticket
  Future<http.Response> addTicket(String token, String date, String time,
      int number, int serviceId, String name, List<int> notifications) async {
    var url = URL_BACKEND + "tickets?api_token=" + token;
    return await http.post(url,
        headers: {
          "content-type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode({
          "date": date,
          "time": time,
          "number": number,
          "name": name,
          "service_id": serviceId,
          "notifications": notifications
        }));
  }

  //reschudle ticket
  Future<http.Response> reschudleTicket(
      String token,
      int ticketId,
      String date,
      String time,
      int number,
      int serviceId,
      String name,
      List<int> notifications) async {
    var url = URL_BACKEND +
        "reschudle/" +
        ticketId.toString() +
        "?api_token=" +
        token;
    return await http.put(url,
        headers: {
          "content-type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode({
          "date": date,
          "time": time,
          "number": number,
          "service_id": serviceId,
          "name": name,
          "notifications": notifications
        }));
  }

  //validate ticket
  Future<http.Response> validateTicket(
      String token, int serviceId, int id, String status, int duration) async {
    var url = URL_BACKEND +
        "validate/" +
        id.toString() +
        "/" +
        serviceId.toString() +
        "?api_token=" +
        token;
    return await http.put(url,
        headers: {
          "content-type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode({"ticket_status": status, "duration": duration}));
  }

  //delete ticket
  Future<http.Response> deleteTicket(String token, int id) async {
    var url = URL_BACKEND + "tickets/" + id.toString() + "?api_token=" + token;
    return await http.delete(url);
  }
}
