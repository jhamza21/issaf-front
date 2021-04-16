class Service {
  int id;
  String title;
  String description;
  int timePerClient;
  int counter;
  String workStartTime;
  String workEndTime;
  List<String> openDays;
  int providerId;
  int userId;
  String status;

  String image;
  Service(
      {this.id,
      this.title,
      this.description,
      this.timePerClient,
      this.counter,
      this.workStartTime,
      this.workEndTime,
      this.openDays,
      this.providerId,
      this.userId,
      this.status,
      this.image});

  Service.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'] ?? '',
        description = json['description'] ?? '',
        timePerClient = json['avg_time_per_client'] ?? null,
        counter = json['counter'] ?? null,
        workStartTime = json['work_start_time'] ?? '',
        workEndTime = json['work_end_time'] ?? '',
        openDays = json['open_days'].cast<String>() ?? null,
        providerId = json['provider_id'] ?? null,
        userId = json['admin_id'] ?? null,
        status = json['status'] ?? '',
        image = json['image'] ?? '';
  static List<Service> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Service.fromJson(value)).toList();
  }
}
