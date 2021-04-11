class User {
  int id;
  String username;
  String name;
  String role;
  String mobile;
  String country;
  String email;
  String password;
  String sexe;
  User(
      {this.id,
      this.username,
      this.name,
      this.role,
      this.email,
      this.password,
      this.country,
      this.sexe,
      this.mobile});

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'] ?? '',
        name = json['name'] ?? '',
        role = json['role'] ?? '',
        mobile = json['mobile'] ?? '',
        country = json['country'] ?? '',
        email = json['email'] ?? '',
        sexe = json['sexe'] ?? '',
        password = json['password'] ?? '';
}
