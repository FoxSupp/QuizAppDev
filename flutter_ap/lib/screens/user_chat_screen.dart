import 'package:flutter/material.dart';
import '../services/socket_service.dart';

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final SocketService _socketService = SocketService();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socketService.socket.on('messageUpdate', (_) => setState(() {}));
    _socketService.socket.on('chatStateUpdate', (_) => setState(() {}));
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      _socketService.sendMessage(_messageController.text.trim());
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hole nur die eigene letzte Nachricht
    final myMessage = _socketService.userMessages[_socketService.socket.id];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Meine Nachricht'),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _socketService.isChatEnabled ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _socketService.isChatEnabled ? 'Aktiv' : 'Gesperrt',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Meine aktuelle Nachricht:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        myMessage != null
                            ? myMessage['message'] as String
                            : 'Noch keine Nachricht gesendet',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: _socketService.isChatEnabled,
                      decoration: InputDecoration(
                        hintText: _socketService.isChatEnabled
                            ? 'Nachricht eingeben...'
                            : 'Chat ist deaktiviert',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed:
                        _socketService.isChatEnabled ? _sendMessage : null,
                    icon: const Icon(Icons.send),
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
