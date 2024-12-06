import 'package:flutter/material.dart';
import '../widgets/buzzer_button.dart';
import '../services/socket_service.dart';
import 'user_chat_screen.dart';
import '../widgets/user_list_widget.dart';

class BuzzerScreen extends StatelessWidget {
  const BuzzerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Buzzer Game'),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Text(
                  'Spieler Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 300,
              child: const UserListWidget(),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserChatScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: BuzzerButton(),
      ),
    );
  }
}
