class User {
  int id;
  String userName;
  String firstName;
  String lastName;
  String email;
  String password;
  String imageUrl;
  String bio;
  User(
      {this.id,
      this.userName,
      this.firstName,
      this.lastName,
      this.email,
      this.password,
      this.imageUrl});

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userName = json['userName'] ?? '',
        firstName = json['firstName'] ?? '',
        lastName = json['lastName'] ?? '',
        email = json['email'] ?? '',
        password = json['password'] ?? '',
        imageUrl = json['imageUrl'] ?? null;
}
