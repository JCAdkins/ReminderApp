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
  }) {
    _validateEmail(email);
    _validatePassword(password);
    _validateName(firstName, "First name");
    _validateName(lastName, "Last name");
  }

  Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
        "first_name": firstName,
        "last_name": lastName,
        "dob": dob.toIso8601String(),
      };

  // ----- Validation Methods -----

  void _validateEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(email)) {
      throw FormatException("Invalid email format");
    }
  }

  void _validatePassword(String password) {
    final specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    if (password.length < 10) {
      throw FormatException("Password must be at least 10 characters long");
    }
    if (!specialCharRegex.hasMatch(password)) {
      throw FormatException("Password must contain at least one special character");
    }
  }

  void _validateName(String name, String fieldName) {
    if (name.trim().isEmpty) {
      throw FormatException("$fieldName cannot be empty");
    }
  }
}
