import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum ListenState { readyToListen, listening, noPermissions }

class ListenService {
  ListenState state = ListenState.readyToListen;
  String text = "";
  SpeechToText stt = SpeechToText();

  StreamController<ListenState> stateStreamController =
      StreamController.broadcast();
  Stream<ListenState> get stateStream => stateStreamController.stream;
  StreamController<String> textStreamController = StreamController.broadcast();
  Stream<String> get textStream => textStreamController.stream;

  ListenService() {
    initializeListening();
  }

  startListening() {
    stt.listen(
      onResult: (SpeechRecognitionResult result) {
        if (result.finalResult && result.alternates.isNotEmpty) {
          text = "$text ${result.alternates[0].recognizedWords}";
          textStreamController.sink.add(text);
          if (state == ListenState.listening) {
            Future.delayed(
              const Duration(milliseconds: 1),
              () {
                startListening();
              },
            ); // phone will cancel listen session on its own.
          }
        }
      },
      listenOptions: SpeechListenOptions(
        autoPunctuation: true,
        listenMode: ListenMode.dictation,
        onDevice: true,
      ),
    );
  }

  Future<bool> initializeListening() async {
    bool result = await stt.initialize(onError: (speechRecognitionError) {
      debugPrint(speechRecognitionError.toString());
    });
    if (result == false) {
      setState(ListenState.noPermissions);
    } else {
      setState(ListenState.readyToListen);
    }
    return true;
  }

  void setState(ListenState newState) {
    state = newState;
    stateStreamController.sink.add(state);
  }

  void stopListening() {
    stt.stop();
  }
}
