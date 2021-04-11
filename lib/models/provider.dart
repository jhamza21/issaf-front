class Provider {
  int id;
  String title;
  String description;
  String coordinates;
  String mobile;
  String email;
  String url;
  String image;
  Provider(
      {this.id,
      this.title,
      this.description,
      this.coordinates,
      this.mobile,
      this.email,
      this.url,
      this.image});

  Provider.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'] ?? '',
        description = json['description'] ?? '',
        coordinates = json['coordinates'] ?? '',
        mobile = json['mobile'] ?? '',
        email = json['email'] ?? '',
        url = json['url'] ?? '',
        image = json['image'] ?? '';
  static List<Provider> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Provider.fromJson(value)).toList();
  }
}
