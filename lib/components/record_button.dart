import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class RecordButton extends StatefulWidget {
  final Function(String) onRecordedText;
  const RecordButton({super.key, required this.onRecordedText});

  @override
  _RecordButtonState createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  final _speech = stt.SpeechToText();
  String _recordedText = '';

  void _startListening() async {
    if (!_speech.isListening) {
      bool available = await _speech.initialize();

      if (available) {
        setState(() {
          _recordedText = '';
        });

        _speech.listen(
          onResult: (result) {
            setState(() {
              _recordedText = result.recognizedWords;
            });
          },
        );
      }
    }
  }

  void _stopRecording() {
    if (_speech.isListening) {
      _speech.stop();
      widget.onRecordedText(
          _recordedText); // Pass recorded text to the parent widget
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_speech.isListening) {
          _stopRecording();
        } else {
          _startListening();
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(_speech.isListening ? Icons.stop : Icons.mic),
        ],
      ),
    );
  }
}
