import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:writing_help/pages/text_page.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(80),
          ),
          child: IconButton(
            onPressed: () async {
              SpeechToText stt = SpeechToText();
              bool available = await stt.initialize();
              if (available) {
                stt.listen(onResult: (SpeechRecognitionResult result) {
                  if (result.finalResult && result.alternates.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (buildContext) {
                        return TextPage(
                            text: result.alternates[0].recognizedWords);
                      }),
                    );
                  }
                });
              } else {}
              Future.delayed(const Duration(seconds: 5))
                  .then((value) => stt.stop());
            },
            icon: const Icon(Icons.mic, size: 80),
            padding: const EdgeInsets.all(14),
          ),
        ),
      ),
    );
  }
}
