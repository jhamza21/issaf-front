class Service {
  int id;
  String title;
  String description;
  String timePerClient;
  String counter;
  String workStartTime;
  String endWorkTime;
  String openDays;
  Status status;

  String image;
  Service(
      {this.id,
      this.title,
      this.description,
      this.timePerClient,
      this.counter,
      this.workStartTime,
      this.endWorkTime,
      this.openDays,
      this.status,
      this.image});

  Service.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'] ?? '',
        description = json['description'] ?? '',
        timePerClient = json['avg_time_per_client'] ?? '',
        counter = json['counter'] ?? '',
        workStartTime = json['work_start_time'] ?? '',
        endWorkTime = json['endWorkTime'] ?? '',
        openDays = json['openDays'] ?? '',
        status = json['status'] ?? '',
        image = json['image'] ?? '';
  static List<Service> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Service.fromJson(value)).toList();
  }
}

enum Status { opened, closed }
