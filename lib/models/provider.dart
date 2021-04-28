class Provider {
  int id;
  String type;
  String title;
  String description;
  String address;
  String mobile;
  String email;
  String url;
  String region;
  String image;
  Provider(
      {this.id,
      this.title,
      this.description,
      this.address,
      this.mobile,
      this.email,
      this.url,
      this.region,
      this.image});

  Provider.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        type = json['type'] ?? '',
        title = json['title'] ?? '',
        description = json['description'] ?? '',
        address = json['address'] ?? '',
        mobile = json['mobile'] ?? '',
        email = json['email'] ?? '',
        url = json['url'] ?? '',
        region = json['region'] ?? '',
        image = json['image'] ?? null;
  static List<Provider> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Provider.fromJson(value)).toList();
  }
}
