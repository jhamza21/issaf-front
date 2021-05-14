class Notification {
  int id;
  int number;
  int idTicket;
  Notification(this.number, this.idTicket);
  Notification.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        number = json['number'] ?? null,
        idTicket = json['ticket_id'] ?? '';
  static List<Notification> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Notification.fromJson(value)).toList();
  }
}
