import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class ChatAppScreen extends StatefulWidget {
  const ChatAppScreen({super.key});

  @override
  State<ChatAppScreen> createState() => _ChatAppScreenState();
}

class _ChatAppScreenState extends State<ChatAppScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {"role": "bot", "text": "Hi! I'm Chatty. How may I help you?", "url": null}
  ];
  bool _isLoading = false; // To show CircularProgressIndicator

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      String userMessage = _controller.text;
      setState(() {
        _messages.insert(0, {"role": "user", "text": userMessage});
        _controller.clear();
        _isLoading = true; // Start loading
      });

      await _getBotResponse(userMessage);
    }
  }

  Future<void> _getBotResponse(String userMessage) async {
  final uri = Uri.parse("http://127.0.0.1:5000/scrape"); // Replace with actual IP
  try {
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"query": userMessage}),
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        _messages.insert(0, {
          "role": "bot",
          "text": responseData["summary"] ?? "No summary available.",
          "url": responseData["url"] ?? null,
        });
      });
    } else {
      throw Exception("Failed with status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e"); // Print error to debug
    setState(() {
      _messages.insert(0, {"role": "bot", "text": "Error: Unable to connect to server", "url": null});
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chatbot", style: TextStyle(fontSize: 26)),
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
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: message["role"] == "user" ? Colors.blueAccent : Colors.grey[700],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message["text"]!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        if (message["url"] != null) // Show Read More link only if URL exists
                          GestureDetector(
                            onTap: () => launchUrl(Uri.parse(message["url"]!)),
                            child: const Text(
                              "Read more",
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      hintStyle: TextStyle(fontWeight: FontWeight.w300),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton(
                    icon: const Icon(Icons.send),
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
