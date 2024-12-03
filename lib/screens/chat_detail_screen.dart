import 'package:atris_peercode/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/openai_service.dart';
import '../models/patient_model.dart';

//Contains chat content
class ChatDetailScreen extends StatefulWidget {
  final String sessionId;
  final Patient patient;

  const ChatDetailScreen({
    super.key,
    required this.sessionId,
    required this.patient,
  });

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _textController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final OpenAIService _openAIService = OpenAIService();

  Future<void> _sendMessage(String content) async {
    if (content.isEmpty) return;

    try {
      await _firestoreService.saveMessage(
        content: content,
        role: 'user',
        sessionId: widget.sessionId,
      );

      final assistantResponse = await _openAIService.getPersonalizedFeedback(widget.patient, content);

      await _firestoreService.saveMessage(
        content: assistantResponse,
        role: 'assistant',
        sessionId: widget.sessionId,
      );

      _textController.clear();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send the message. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat Details')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<QueryDocumentSnapshot>>(
              stream: _firestoreService.getMessagesForSession(widget.sessionId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages for this session.'));
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final content = message['content'] ?? '';
                    final role = message['role'] ?? 'user';

                    return ListTile(
                      title: Text(
                        content,
                        style: TextStyle(
                          color: role == 'user' ? Colors.blue : Colors.black,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _sendMessage(_textController.text),
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
