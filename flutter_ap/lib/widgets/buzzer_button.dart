import 'package:flutter/material.dart';
import '../services/socket_service.dart';

class BuzzerButton extends StatefulWidget {
  const BuzzerButton({super.key});

  @override
  State<BuzzerButton> createState() => _BuzzerButtonState();
}

class _BuzzerButtonState extends State<BuzzerButton> {
  final SocketService _socketService = SocketService();
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socketService.socket.on('buzzerLocked', (username) {
      setState(() {});
      _showBuzzerResult(username);
    });

    _socketService.socket.on('subsequentPress', (data) {
      _showSubsequentPress(data);
    });

    _socketService.socket.on('buzzersReset', (_) {
      setState(() {});
    });
  }

  void _showBuzzerResult(String username) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$username hat zuerst gedrückt!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showSubsequentPress(Map<String, dynamic> data) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${data['username']} hat nach ${data['timeDiff']} Sekunden gedrückt'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLocked = _socketService.isBuzzerLocked;

    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade500,
            offset: const Offset(8, 8),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-8, -8),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: Transform.scale(
          scale: _isPressed ? 0.95 : 1.0,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isLocked ? Colors.grey : Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(60),
              shape: const CircleBorder(
                side: BorderSide(
                  color: Colors.grey,
                  width: 6,
                ),
              ),
              elevation: _isPressed ? 5 : 15,
            ),
            onPressed: isLocked ? null : () => _socketService.pressBuzzer(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'BUZZER',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isLocked) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Gewinner: ${_socketService.firstPresser}',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
