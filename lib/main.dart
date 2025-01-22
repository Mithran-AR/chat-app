import 'package:aiapp/keys.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

import 'model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}
class _HomeState extends State<Home> {
  TextEditingController promptController = TextEditingController();
  ScrollController scrollController = ScrollController(); // Add a ScrollController

  final model = GenerativeModel(model: "gemini-pro", apiKey: ApiKeys.apiKey);
  final List<ModelMessage> prompts = [];
  final bool isPrompt = true;

  Future<void> sendMessage() async {
    final message = promptController.text;
    setState(() {
      promptController.clear();
      prompts.add(ModelMessage(
        isprompt: true,
        messege: message,
        time: DateTime.now(),
      ));
    });

    // Scroll to the bottom after adding the user's message
    scrollToBottom();

    final content = [Content.text(message)];
    final response = await model.generateContent(content);
    setState(() {
      prompts.add(ModelMessage(
        isprompt: false,
        messege: response.text ?? "",
        time: DateTime.now(),
      ));
    });

    // Scroll to the bottom after adding the AI's response
    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    promptController.dispose();
    scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "AI Chat",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController, // Assign the ScrollController
                itemCount: prompts.length,
                padding: const EdgeInsets.all(15),
                itemBuilder: (context, index) {
                  final message = prompts[index];
                  return userPrompt(
                    isPrompt: message.isprompt,
                    message: message.messege,
                    date: DateFormat('hh:mm a').format(message.time),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: promptController,
                      style: const TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        hintText: "Enter your prompt...",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: const Icon(Icons.edit, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Colors.green, Colors.teal],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget userPrompt({
    required bool isPrompt,
    required String message,
    required String date,
  }) {
    return Align(
      alignment: isPrompt ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPrompt ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isPrompt ? const Radius.circular(12) : Radius.zero,
            bottomRight: isPrompt ? Radius.zero : const Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          isPrompt ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isPrompt ? FontWeight.bold : FontWeight.normal,
                color: isPrompt ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              date,
              style: TextStyle(
                fontSize: 12,
                color: isPrompt ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
