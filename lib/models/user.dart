class User {
  int id;
  String userName;
  String name;
  String mobile;
  String email;
  String password;
  String bio;
  User({this.id, this.userName, this.name, this.email, this.password});

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userName = json['userName'] ?? '',
        name = json['name'] ?? null,
        mobile = json['mobile'] ?? null,
        email = json['email'] ?? '',
        password = json['password'] ?? '';
}
