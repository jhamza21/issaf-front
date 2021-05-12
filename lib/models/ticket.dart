import 'package:issaf/models/service.dart';

class Ticket {
  int id;
  int number;
  String date;
  String time;
  String status;
  Service service;
  String name;
  int duration;
  Ticket(
      {this.id,
      this.number,
      this.date,
      this.time,
      this.service,
      this.status,
      this.name,
      this.duration});

  Ticket.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        number = json['number'] ?? null,
        date = json['date'] ?? '',
        time = json['time'] ?? '',
        service =
            json['service'] != null ? Service.fromJson(json['service']) : null,
        status = json['status'] ?? '',
        name = json['name'] ?? '',
        duration = json['duration'] ?? '';

  static List<Ticket> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Ticket.fromJson(value)).toList();
  }
}
