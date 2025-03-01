import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatAppScreen extends StatefulWidget {
  const ChatAppScreen({super.key});

  @override
  State<ChatAppScreen> createState() => _ChatAppScreenState();
}

class _ChatAppScreenState extends State<ChatAppScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {"role": "bot", "text": "Hi! I'm Chatty. How may I help you?"}
  ];

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      String userMessage = _controller.text;
      setState(() {
        _messages.insert(0, {"role": "user", "text": userMessage});
        _controller.clear();
      });

      await _getBotResponse(userMessage);
    }
  }

  Future<void> _getBotResponse(String userMessage) async {
    final uri = Uri.parse("http://127.0.0.1:5000/chat");
    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": userMessage}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _messages.insert(0, {"role": "bot", "text": responseData["response"]});
        });
      } else {
        throw Exception("Failed to get response");
      }
    } catch (e) {
      setState(() {
        _messages.insert(0, {"role": "bot", "text": "Error: Unable to connect to server"});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatbot", style: TextStyle(fontSize: 26)),
        elevation: 5,
        centerTitle: true,
        backgroundColor: Colors.blue[400],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message["role"] == "user" ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: message["role"] == "user" ? Colors.blueAccent : Colors.grey[700],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message["text"]!,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(fontWeight: FontWeight.w300),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
