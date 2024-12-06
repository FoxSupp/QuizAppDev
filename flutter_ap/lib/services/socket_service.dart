import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;

  // User state
  String? currentUsername;

  // Buzzer state
  bool isBuzzerLocked = false;
  String? firstPresser;
  List<Map<String, dynamic>> subsequentPresses = [];

  // Chat state
  bool isChatEnabled = false;
  Map<String, Map<String, dynamic>> userMessages = {};
  List<String> connectedUsers = [];
  Set<String> clearedMessages = {}; // Neue Set für gelöschte Nachrichten

  factory SocketService() {
    return _instance;
  }

  SocketService._internal() {
    socket = IO.io(
        'https://server.sascha-belau.com:3000',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableForceNew()
            .enableAutoConnect()
            .setExtraHeaders({'Access-Control-Allow-Origin': '*'})
            .build());

    socket.connect();

    socket.onConnect((_) {
      print('Socket Connection established');
    });

    // Buzzer Events
    socket.on('buzzerState', (data) {
      print('Received buzzer state: $data');
      if (data is Map) {
        isBuzzerLocked = data['buzzerLocked'] ?? false;
        firstPresser = data['firstPresser'];
        if (data['subsequentPresses'] != null) {
          subsequentPresses =
              List<Map<String, dynamic>>.from(data['subsequentPresses']);
        }
        isChatEnabled = data['chatEnabled'] ?? false;
      }
    });

    socket.on('buzzerLocked', (data) {
      print('Buzzer locked by: $data');
      isBuzzerLocked = true;
      if (data is String) {
        firstPresser = data;
      }
    });

    socket.on('subsequentPress', (data) {
      print('Subsequent press: $data');
      if (data is Map && data['allPresses'] != null) {
        subsequentPresses = List<Map<String, dynamic>>.from(data['allPresses']);
      }
    });

    socket.on('buzzersReset', (_) {
      print('Buzzers reset');
      isBuzzerLocked = false;
      firstPresser = null;
      subsequentPresses.clear();
    });

    // Chat Events
    socket.on('chatStateUpdate', (enabled) {
      print('Chat state updated: $enabled');
      isChatEnabled = enabled as bool;
    });

    socket.on('messageUpdate', (data) {
      print('Message update received: $data');
      if (data is List) {
        userMessages.clear();
        for (var item in data) {
          if (item is List && item.length == 2) {
            String username = item[0];
            Map<String, dynamic> messageData =
                Map<String, dynamic>.from(item[1]);
            userMessages[username] = messageData;
          }
        }
      }
    });

    socket.on('userListUpdate', (users) {
      print('User list updated: $users');
      connectedUsers = List<String>.from(users);
    });

    socket.onError((error) => print('Socket Error: $error'));
    socket.onDisconnect((_) => print('Socket Disconnected'));
  }

  void setUsername(String username) {
    print('Setting username: $username');
    currentUsername = username;
    socket.emit('setUsername', username);
  }

  void pressBuzzer() {
    print('Pressing buzzer');
    socket.emit('buzzerPressed');
  }

  void resetBuzzer() {
    print('Resetting buzzer');
    socket.emit('resetBuzzers');
  }

  void toggleChat() {
    print('Toggling chat');
    socket.emit('toggleChat');
  }

  void sendMessage(String message) {
    print('Sending message: $message');
    socket.emit('sendMessage', message);
  }

  // Neue Methode zum Löschen der lokalen Nachrichten
  void clearLocalMessages() {
    print('Clearing local messages');
    userMessages.clear();
  }

  void dispose() {
    socket.dispose();
  }
}
