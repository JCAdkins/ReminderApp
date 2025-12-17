// ignore_for_file: non_constant_identifier_names

class User {
  final String id;
  final String email;
  final String first_name;
  final String last_name;

  User(
      {required this.id,
      required this.email,
      required this.first_name,
      required this.last_name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json["id"].toString(),
        email: json["email"],
        first_name: json["first_name"],
        last_name: json["last_name"]);
  }
}
