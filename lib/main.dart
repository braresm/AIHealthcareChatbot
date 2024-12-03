import 'package:atris_peercode/models/patient_model.dart';
import 'package:atris_peercode/screens/activity_screen.dart';
import 'package:atris_peercode/screens/chat_screen.dart';
import 'package:atris_peercode/screens/user_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'services/notification_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity Coaching App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      home: UserPageScreen( //Toggle between pages by changing the home screen to ActivityScreen/ChatScreen/UserPageScreen
      patient: Patient(
        name: 'John Doe',
        age: 45,
        dailySteps: 5000,
        activityLevel: 'Moderate',
        goal: '10,000 steps daily',
        physicalLimitation: 'None',
        discType: 'D',
      ),
    ),
    );
  }
}
