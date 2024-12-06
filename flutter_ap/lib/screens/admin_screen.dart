import 'package:flutter/material.dart';
import '../services/socket_service.dart';
import 'admin_chat_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final SocketService socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    socketService.socket.on('buzzerState', (_) {
      print('Buzzer state updated in UI');
      setState(() {});
    });
    socketService.socket.on('buzzerLocked', (_) {
      print('Buzzer locked in UI');
      setState(() {});
    });
    socketService.socket.on('subsequentPress', (_) {
      print('Subsequent press in UI');
      setState(() {});
    });
    socketService.socket.on('buzzersReset', (_) {
      print('Buzzers reset in UI');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isBuzzerLocked = socketService.isBuzzerLocked;
    final String? firstPresser = socketService.firstPresser;
    final subsequentPresses = socketService.subsequentPresses;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Buzzer Dashboard'),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat Verwaltung'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminChatScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buzzer Status',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isBuzzerLocked ? 'Gesperrt' : 'Bereit',
                        style: TextStyle(
                          color: isBuzzerLocked ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (firstPresser != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Erster Buzzer',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          firstPresser,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (subsequentPresses.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nachfolgende Buzzer',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: subsequentPresses.length,
                            itemBuilder: (context, index) {
                              final press = subsequentPresses[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text('${index + 2}'),
                                ),
                                title: Text(press['username'] as String),
                                trailing: Text(
                                  '+${press['timeDiff']}s',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed:
                    isBuzzerLocked ? () => socketService.resetBuzzer() : null,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'RESET BUZZER',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
