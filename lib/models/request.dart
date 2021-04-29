import 'package:issaf/models/service.dart';
import 'package:issaf/models/user.dart';

class Request {
  int id;
  String dateTime;
  User sender;
  User receiver;
  Service service;
  String status;
  Request(
      {this.id,
      this.dateTime,
      this.sender,
      this.receiver,
      this.service,
      this.status});

  Request.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        dateTime = json['date_time'] ?? '',
        sender = User.fromJson(json['sender']),
        receiver = User.fromJson(json['receiver']),
        service = Service.fromJson(json['service']),
        status = json['status'] ?? null;

  static List<Request> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Request.fromJson(value)).toList();
  }
}
