import 'package:flutter/material.dart';
import '../services/socket_service.dart';

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socketService.socket.on('chatStateUpdate', (_) {
      print('Chat state updated in UI');
      setState(() {});
    });
    _socketService.socket.on('messageUpdate', (_) {
      print('Message update in UI');
      setState(() {});
    });
    _socketService.socket.on('userListUpdate', (_) {
      print('User list update in UI');
      setState(() {});
    });
  }

  void _clearMessages() {
    setState(() {
      _socketService.clearLocalMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userList = _socketService.connectedUsers
        .where((username) => username != _socketService.currentUsername)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Verwaltung'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Nachrichten löschen',
            onPressed: _clearMessages,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  _socketService.isChatEnabled ? 'Chat aktiv' : 'Chat gesperrt',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _socketService.isChatEnabled,
                  onChanged: (_) {
                    _socketService.toggleChat();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.group),
                const SizedBox(width: 8),
                Text(
                  'Online Users (${userList.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: userList.isEmpty
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
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      final username = userList[index];
                      final lastMessage = _socketService.userMessages[username];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(username),
                          subtitle: lastMessage != null
                              ? Text(
                                  lastMessage['message'] as String,
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              : const Text(
                                  'Noch keine Nachricht',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                          trailing: lastMessage != null
                              ? Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          lastMessage['timestamp'] as int)
                                      .toLocal()
                                      .toString()
                                      .split(' ')[1],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
