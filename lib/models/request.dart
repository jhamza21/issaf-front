class Request {
  int id;
  String dateTime;
  int senderId;
  int receiverId;
  int serviceId;
  String status;
  Request(
      {this.id,
      this.dateTime,
      this.senderId,
      this.receiverId,
      this.serviceId,
      this.status});

  Request.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        dateTime = json['date_time'] ?? '',
        senderId = json['sender_id'] ?? '',
        receiverId = json['receiver_id'] ?? '',
        serviceId = json['service_id'] ?? '',
        status = json['status'] ?? '';

  static List<Request> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Request.fromJson(value)).toList();
  }
}
