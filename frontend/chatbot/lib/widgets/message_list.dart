import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;

  const MessageList({
    super.key,
    this.messages = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return Container(
          margin: EdgeInsets.only(
            top: 8,
            bottom: 8,
            left: message.isUser ? 64 : 8,
            right: message.isUser ? 8 : 64,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: message.isUser ? Colors.blue : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: message.isUser ? Colors.white : Colors.black87,
            ),
          ),
        );
      },
    );
  }
}