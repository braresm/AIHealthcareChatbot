import 'dart:convert';
import 'package:atris_peercode/models/patient_model.dart';
import 'package:http/http.dart' as http;
import '../secrets.dart';

class OpenAIService{
  String get apiKey => 'openaiKey';

  Future<String> getPersonalizedFeedback(Patient patient, String message) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final systemMessage = _getSystemMessage(patient);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            "role": "system",
            "content": systemMessage,
          },
          { 
            'role': 'user', 
            'content': message 
          }
        ],
        'max_tokens': 100,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Failed to load response from OpenAI: ${response.body}');
    }
  }
  
  _getSystemMessage(Patient patient) {
    String coachingStyle = _getCoachingStyle(patient.discType);

    return '''
        You are a health assistant chatbot. Your coaching style is: $coachingStyle
        Patient Information:
        - Name: ${patient.name}
        - Age: ${patient.age}
        - Daily Steps: ${patient.dailySteps}
        - Activity Level: ${patient.activityLevel}
        - Goal: ${patient.goal}
        - Physical Limitation: ${patient.physicalLimitation}

        You are dedicated to helping patients improve their well-being through
        motivational messages and constructive feedback based on the patient's recent activity data.
        Do not give any medical advice.
        Only motivate the patient to finish their goals.
        You tailor your advice to encourage patients while considering their progress, physical limitations, and goals. 
        Give suggestions based on the patient's coaching style.
        Give shorter, more direct responses up to 100 tokens.
        ''';
  }

  String _getCoachingStyle(String discType) {
    switch (discType) {
      case 'D':
        return 'Direct and results-oriented. You challenge the patient to achieve their goals quickly and efficiently.';
      case 'I':
        return 'Enthusiastic and friendly. You encourage the patient with positive reinforcement and social engagement.';
      case 'S':
        return 'Supportive and patient. You emphasize consistency and provide reassurance.';
      case 'C':
        return 'Detailed and analytical. You provide data-driven insights and structured plans.';
      default:
        return 'Balanced and adaptable. You adjust your coaching style to the patient\'s needs.';
    }
  }
}