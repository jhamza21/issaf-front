import 'package:issaf/models/service.dart';

class Ticket {
  int id;
  int number;
  String date;
  String time;
  String status;
  Service service;
  Ticket(
      {this.id, this.number, this.date, this.time, this.service, this.status});

  Ticket.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        number = json['number'] ?? null,
        date = json['date'] ?? '',
        time = json['time'] ?? '',
        service = Service.fromJson(json['service']) ?? null,
        status = json['status'] ?? '';

  static List<Ticket> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Ticket.fromJson(value)).toList();
  }
}
