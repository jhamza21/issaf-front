class User {
  int id;
  String username;
  String name;
  String mobile;
  String email;
  String password;
  String region;
  String status;
  User(
      {this.id,
      this.username,
      this.name,
      this.email,
      this.password,
      this.region,
      this.status,
      this.mobile});

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'] ?? '',
        name = json['name'] ?? '',
        mobile = json['mobile'] ?? '',
        email = json['email'] ?? '',
        region = json['region'] ?? '',
        status = json['status'] ?? null,
        password = json['password'] ?? '';

  static List<User> listFromJson(List<dynamic> json) {
    return json == null
        ? []
        : json.map((value) => User.fromJson(value)).toList();
  }
}
