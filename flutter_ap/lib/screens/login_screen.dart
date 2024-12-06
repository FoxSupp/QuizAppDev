import 'package:flutter/material.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: const Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: LoginForm(),
        ),
      ),
    );
  }
} 