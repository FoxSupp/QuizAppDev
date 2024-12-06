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
            .setTimeout(5000)
            .build());

    try {
      socket.connect();
      print('Attempting to connect to WebSocket...');
    } catch (e) {
      print('Connection attempt failed: $e');
    }

    socket.onConnect((_) {
      print('Socket Connection established successfully');
    });

    socket.onConnectError((data) {
      print('Connect Error: $data');
      socket.disconnect();
    });

    socket.onError((data) {
      print('Socket Error: $data');
      socket.disconnect();
    });

    socket.onDisconnect((_) {
      print('Socket Disconnected');
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
  }

  Future<void> setUsername(String username) {
    return Future(() {
      print('Setting username: $username');
      currentUsername = username;
      socket.emit('setUsername', username);
    });
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
    print('Clearing messages on server');
    socket.emit('clearMessages'); // Neue Server-Event
    userMessages.clear();
  }

  void dispose() {
    socket.dispose();
  }

  void disconnectAllUsers() {
    socket.emit('disconnectAllUsers');
  }
}
