class AppConfig {
  static const String serverUrl = 'https://server.sascha-belau.com:3000';
  static const int socketTimeout = 5000;
  static const int reconnectAttempts = 3;
  static const Duration reconnectDelay = Duration(seconds: 2);
  
  // Message settings
  static const int maxMessageLength = 500;
} 