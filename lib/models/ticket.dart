class Ticket {
  int id;
  int number;
  String date;
  String title;
  String description;
  Status status;
  Ticket(
      {this.id,
      this.number,
      this.date,
      this.title,
      this.description,
      this.status});

  Ticket.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        number = json['number'] ?? null,
        date = json['date'] ?? '',
        title = json['title'] ?? '',
        description = json['description'] ?? '',
        status = json['status'] ?? '';

  static List<Ticket> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Ticket.fromJson(value)).toList();
  }
}

enum Status { IN_PROGRESS, DONE, UNDONE }
