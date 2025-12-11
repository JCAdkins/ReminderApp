class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final DateTime dob;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.dob,
  });

  Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
        "first_name": firstName,
        "last_name": lastName,
        "dob": dob.toIso8601String(),
      };
}
