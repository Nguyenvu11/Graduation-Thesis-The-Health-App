import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final messageInsert = TextEditingController();
  List<Map> messages = [];

  Future<Map<String, String>> fetchBotResponse(String userMessage) async {
    const apiUrl = 'http://10.50.42.188:5000/predict';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'tag': data['tag'],
          'response': data['response'],
        };
      } else {
        print("Error from server: ${response.body}");
        return {
          'tag': "Error",
          'response': "Sorry, something went wrong.",
        };
      }
    } catch (e) {
      print("Error connecting to API: $e");
      return {
        'tag': "Error",
        'response': "Sorry, I couldn't connect to the server.",
      };
    }
  }

  void handleUserMessage(String userMessage) async {
    setState(() {
      messages.insert(0, {"data": 1, "message": userMessage});
    });

    // Send request to the Flask API
    Map<String, String> botResponse = await fetchBotResponse(userMessage);

    setState(() {
      messages.insert(0, {"data": 0, "message": botResponse['response']});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HealthBot"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) => chat(
                  messages[index]["message"].toString(),
                  messages[index]["data"]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: messageInsert,
                      decoration: const InputDecoration.collapsed(
                          hintText: "Enter symptoms separated by commas"),
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.send, size: 30.0, color: Colors.teal),
                    onPressed: () {
                      if (messageInsert.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please enter your message")));
                      } else {
                        handleUserMessage(messageInsert.text);
                        messageInsert.clear();
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget chat(String message, int data) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Bubble(
        radius: const Radius.circular(15.0),
        color: data == 0 ? Colors.lightBlueAccent : Colors.orangeAccent,
        alignment: data == 0 ? Alignment.topLeft : Alignment.topRight,
        nip: data == 0 ? BubbleNip.leftBottom : BubbleNip.rightTop,
        child: Text(
          message,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
    );
  }
}
