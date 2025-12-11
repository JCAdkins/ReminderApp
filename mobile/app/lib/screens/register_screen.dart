import 'package:flutter/material.dart';
import '../api/auth_service.dart';
import '../api/models/register_request.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  final auth = AuthService();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: firstNameCtrl,
                decoration: const InputDecoration(labelText: "First Name"),
              ),
              TextField(
                controller: lastNameCtrl,
                decoration: const InputDecoration(labelText: "Last Name"),
              ),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              TextField(
                controller: dobCtrl,
                decoration: const InputDecoration(
                  labelText: "Date of Birth",
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000, 1, 1),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (selectedDate != null) {
                    dobCtrl.text =
                        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                  }
                },
              ),
              const SizedBox(height: 20),

              /// REGISTER BUTTON
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        setState(() => loading = true);

                        final selectedDob = DateTime.tryParse(dobCtrl.text);

                        if (selectedDob == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please select a valid date of birth")),
                        );
                        setState(() => loading = false);
                        return;
                        }

                        final request = RegisterRequest(
                        firstName: firstNameCtrl.text,
                        lastName: lastNameCtrl.text,
                        email: emailCtrl.text,
                        password: passCtrl.text,
                        dob: selectedDob, // <-- pass DateTime here
                        );

                        final response = await auth.register(request);

                        setState(() => loading = false);

                        if (response.accessToken != null && response.accessToken!.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Registered successfully!")),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Registration failed")),
                          );
                        }
                      },
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Register"),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
