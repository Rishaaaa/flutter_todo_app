import 'package:flutter/material.dart';

enum MessageType { success, error }

class ScaffoldMessage {
  static void show(BuildContext context, MessageType type, String message) {
    final color = type == MessageType.success ? Colors.green : Colors.red;
    final icon = type == MessageType.success ? Icons.check_circle : Icons.error;

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
