import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final Function(String)? onSubmitted;
  final TextEditingController controller;

  const ChatInput({
    super.key,
    this.onSubmitted,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              decoration: const InputDecoration.collapsed(
                hintText: 'Type a message...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (controller.text.isNotEmpty && onSubmitted != null) {
                onSubmitted!(controller.text);
              }
            },
          ),
        ],
      ),
    );
  }
}