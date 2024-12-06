import 'package:flutter/material.dart';
import '../screens/buzzer_screen.dart';
import '../screens/admin_screen.dart';
import '../services/socket_service.dart';

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
  void initState() {
    super.initState();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socketService.socket.on('duplicateUsername', (_) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dieser Benutzername ist bereits vergeben!'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _onJoinPressed() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      _socketService.setUsername(_usernameController.text);

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  _isAdmin ? const AdminScreen() : const BuzzerScreen(),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Willkommen zum Buzzer!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
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
              onChanged: (bool value) {
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAdmin ? Colors.red : Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isAdmin ? 'ALS ADMIN BEITRETEN' : 'BEITRETEN',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
