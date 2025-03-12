import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carsharing/components/textfield.dart';
import 'package:carsharing/components/button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();
  bool hasDrivingLicense = false;

  Future<void> _registerUser(BuildContext context) async {
    String url = kIsWeb ? 'http://localhost:3000/register' : 'http://10.0.2.2:3000/register';

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": userNameController.text,
        "password": passwordController.text,
        "repeatPassword": repeatPasswordController.text,
        "hasDrivingLicense": hasDrivingLicense
      }),
    );

    if (response.statusCode == 200) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      final errorMessage = jsonDecode(response.body)['error'];
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth > 600 ? 400 : constraints.maxWidth * 0.9;
            return Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: width,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Register',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Username Field
                    MyTextField(
                      controller: userNameController,
                      hintText: 'Username',
                      obscureText: false,
                    ),
                    const SizedBox(height: 10),

                    // Password Field
                    MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),

                    // Repeat Password Field
                    MyTextField(
                      controller: repeatPasswordController,
                      hintText: 'Repeat Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),

                    // Driving License Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: hasDrivingLicense,
                          onChanged: (value) {
                            setState(() {
                              hasDrivingLicense = value!;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text('I have a driving license'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Register Button
                    MyButton(
                      text: 'Register',
                      onTap: () => _registerUser(context),
                    ),
                    const SizedBox(height: 10),

                    // Back to Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already registered?'),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Back to login',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
