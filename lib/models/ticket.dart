import 'package:issaf/models/notification.dart';
import 'package:issaf/models/service.dart';
import 'package:issaf/models/user.dart';

class Ticket {
  int id;
  int number;
  String date;
  String time;
  String status;
  Service service;
  User user;
  String name;
  int duration;
  List<Notification> notifications;
  Ticket(
      {this.id,
      this.number,
      this.date,
      this.time,
      this.service,
      this.user,
      this.status,
      this.name,
      this.duration,
      this.notifications});

  Ticket.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        number = json['number'] ?? null,
        date = json['date'] ?? '',
        time = json['time'] ?? '',
        service =
            json['service'] != null ? Service.fromJson(json['service']) : null,
        status = json['status'] ?? '',
        name = json['name'] ?? '',
        user = json["user"] != null ? User.fromJson(json["user"]) : null,
        duration = json['duration'] ?? '',
        notifications = json["notifications"] != null
            ? Notification.listFromJson(json["notifications"])
            : [];
  static List<Ticket> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Ticket.fromJson(value)).toList();
  }
}
