import 'package:atris_peercode/models/patient_model.dart';
import 'package:flutter/material.dart';

//Contains the Activity level of the user including some suggestions on how to improve it
class ActivityScreen extends StatelessWidget {
  final Patient patient;

  const ActivityScreen({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      final String resolvedDiscType = getDiscType(patient.discType);
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text(
                  'Daily Steps: ${patient.dailySteps}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 8),
                Text(
                  'Activity Level: ${patient.activityLevel}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 8),
                Text(
                  'Goal: ${patient.goal}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 8),
                Text(
                  'Physical Limitation: ${patient.physicalLimitation}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 8),
                Text(
                  'Disc Type: $resolvedDiscType',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String getDiscType(String discType) {
  switch(discType){
    case "D":
      return "Direct and results-oriented. You challenge the patient to achieve their goals quickly and efficiently.";
    case "I":
      return "Enthusiastic and friendly. You encourage the patient with positive reinforcement and social engagement.";
    case "S":
      return "Supportive and patient. You emphasize consistency and provide reassurance.";
    case "C":
      return "Detailed and analytical. You provide data-driven insights and structured plans.";
    default:
      return "Balanced and adaptable. You adjust your coaching style to the patient\'s needs.";
  }
}