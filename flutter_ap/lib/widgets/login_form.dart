import 'package:flutter/material.dart';
import '../screens/buzzer_screen.dart';
import '../screens/admin_screen.dart';
import '../services/socket_service.dart';
import '../config/app_config.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final SocketService _socketService = SocketService();
  bool _isLoading = false;
  bool _isAdmin = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _onJoinPressed() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _socketService.setUsername(_usernameController.text);
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  _isAdmin ? const AdminScreen() : const BuzzerScreen(),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Verbinden: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Benutzername',
              hintText: 'Gib deinen Benutzernamen ein',
              prefixIcon: Icon(Icons.person),
            ),
            enabled: !_isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bitte gib einen Benutzernamen ein';
              }
              if (value.length < 3) {
                return 'Der Benutzername muss mindestens 3 Zeichen lang sein';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            title: const Text('Als Admin anmelden'),
            value: _isAdmin,
            onChanged: _isLoading
                ? null
                : (bool value) {
                    setState(() {
                      _isAdmin = value;
                    });
                  },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onJoinPressed,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Beitreten'),
            ),
          ),
        ],
      ),
    );
  }
}
