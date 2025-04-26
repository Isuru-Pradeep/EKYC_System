import 'package:flutter/material.dart';

class KYCChatScreen extends StatefulWidget {
  const KYCChatScreen({super.key});

  @override
  State<KYCChatScreen> createState() => _KYCChatScreenState();
}

class _KYCChatScreenState extends State<KYCChatScreen> {
  final List<String> messages = [
    "Let's start with your full name.",
  ];
  final TextEditingController _controller = TextEditingController();
  int step = 0;

  void _sendMessage(String message) {
    setState(() {
      messages.add("You: $message");

      if (step == 0) {
        messages.add("Nice to meet you, $message! What's your date of birth?");
        step++;
      } else if (step == 1) {
        messages.add("Got it! Now please enter your email address.");
        step++;
      } else if (step == 2) {
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        if (!emailRegex.hasMatch(message)) {
          messages.add("❗ That doesn't look like a valid email. Please try again.");
          return;
        }
        messages.add("Thanks! 🎉 You're all set.");
        step++;
      }

      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KYC Chat"),
        backgroundColor: Colors.blue[800],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  alignment: messages[index].startsWith("You:")
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: messages[index].startsWith("You:")
                          ? Colors.blue[100]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(messages[index]),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type your response...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      _sendMessage(_controller.text.trim());
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
