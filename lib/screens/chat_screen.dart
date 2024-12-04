import 'package:atris_peercode/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:atris_peercode/models/patient_model.dart';
import 'package:atris_peercode/screens/chat_detail_screen.dart';
import 'package:atris_peercode/utils/session_utils.dart';
import 'package:atris_peercode/services/firestore_service.dart';

//Contains chat sessions
class ChatScreen extends StatefulWidget {
  final Patient patient;

  const ChatScreen({super.key, required this.patient});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeChatSession();
    immediateNotification();
  }

  Future<void> _initializeChatSession() async {
    final sessionTitle = generateSessionTitle();
    final sessionId = await _firestoreService.createSession(sessionTitle);

    // if (mounted) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => ChatDetailScreen(
    //         sessionId: sessionId,
    //         patient: widget.patient,
    //       ),
    //     ),
    //   );
    // }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _confirmDeleteSession(String sessionId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Session'),
          content: const Text(
              'Are you sure you want to delete this session? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _firestoreService.deleteSession(sessionId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session deleted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Health Assistant Chat')),
      body: StreamBuilder<Map<String, List<QueryDocumentSnapshot>>>(
        stream: _firestoreService.getGroupedSessionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No chat sessions available.'));
          }

          final groupedSessions = snapshot.data!;
          return ListView(
            children: groupedSessions.entries.map((entry) {
              final sectionTitle = entry.key;
              final sessions = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      sectionTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...sessions.map((session) {
                    final sessionTitle = session['title'] ?? 'Untitled Session';

                    return ListTile(
                      title: Text(sessionTitle),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDeleteSession(session.id),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              sessionId: session.id,
                              patient: widget.patient,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
