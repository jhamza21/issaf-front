class Provider {
  int id;
  String name;
  String description;
  String address;
  Provider({this.id, this.name, this.description, this.address});

  Provider.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'] ?? '',
        description = json['description'] ?? '',
        address = json['address'] ?? '';

  static List<Provider> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => Provider.fromJson(value)).toList();
  }
}
