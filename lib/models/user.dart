class User {
  int id;
  String username;
  String name;
  String role;
  String mobile;
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
      this.sexe,
      this.mobile});

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'] ?? '',
        name = json['name'] ?? '',
        role = json['role'] ?? '',
        mobile = json['mobile'] ?? '',
        email = json['email'] ?? '',
        sexe = json['sexe'] ?? '',
        password = json['password'] ?? '';
}
