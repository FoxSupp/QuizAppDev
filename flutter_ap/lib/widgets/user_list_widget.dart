import 'package:flutter/material.dart';
import '../services/socket_service.dart';

class UserListWidget extends StatefulWidget {
  const UserListWidget({super.key});

  @override
  State<UserListWidget> createState() => _UserListWidgetState();
}

class _UserListWidgetState extends State<UserListWidget> {
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _socketService.socket.on('userListUpdate', (_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final users = _socketService.connectedUsers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.group),
              const SizedBox(width: 8),
              Text(
                'Verbundene Spieler (${users.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: users.isEmpty
              ? const Center(
                  child: Text(
                    'Keine Spieler online',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(users[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
