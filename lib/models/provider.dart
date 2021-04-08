class Provider {
  int id;
  String name;
  String description;
  String address;
  String image;
  Provider({this.id, this.name, this.description, this.address, this.image});

  Provider.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'] ?? '',
        description = json['description'] ?? '',
        address = json['address'] ?? '',
        image = json['image'] ?? '';
  static List<Provider> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Provider.fromJson(value)).toList();
  }
}
