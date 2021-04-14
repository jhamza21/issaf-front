class Provider {
  int id;
  String title;
  String description;
  String address;
  String mobile;
  String email;
  String url;
  String image;
  Provider(
      {this.id,
      this.title,
      this.description,
      this.address,
      this.mobile,
      this.email,
      this.url,
      this.image});

  Provider.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'] ?? '',
        description = json['description'] ?? '',
        address = json['address'] ?? '',
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
