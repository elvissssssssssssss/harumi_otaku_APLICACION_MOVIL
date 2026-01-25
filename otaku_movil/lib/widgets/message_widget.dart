
// lib/widgets/message_widget.dart
import 'package:flutter/material.dart';

class MessageWidget extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback? onDismiss;
  
  const MessageWidget({
    Key? key,
    required this.message,
    required this.isError,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isError ? Colors.red[50] : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: isError ? Colors.red[700] : Colors.green[700],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isError ? Colors.red[700] : Colors.green[700],
                  fontSize: 14,
                ),
              ),
            ),
            if (onDismiss != null)
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close),
                iconSize: 20,
                color: isError ? Colors.red[700] : Colors.green[700],
              ),
          ],
        ),
      ),
    );
  }
}