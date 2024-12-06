import 'package:flutter/material.dart';

void showBuzzerAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Buzzer Alert'),
        content: const Text('Du hast den Buzzer gedrückt!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
} 