class Ticket {
  int id;
  int number;
  String date;
  String time;
  String title;
  String description;
  String status;
  Ticket(
      {this.id,
      this.number,
      this.date,
      this.time,
      this.title,
      this.description,
      this.status});

  Ticket.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        number = json['number'] ?? null,
        date = json['date'] ?? '',
        time = json['time'] ?? '',
        title = json['title'] ?? '',
        description = json['description'] ?? '',
        status = json['status'] ?? '';

  static List<Ticket> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Ticket.fromJson(value)).toList();
  }
}
