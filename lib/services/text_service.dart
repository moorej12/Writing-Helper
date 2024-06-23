import 'dart:async';

import 'package:writing_help/services/listen_service.dart';

class TextService {
  ListenService listenService;
  String text = "";

  StreamController<String> textStreamController = StreamController.broadcast();
  Stream<String> get textStream => textStreamController.stream;

  TextService(this.listenService) {
    listenService.textStream.listen((newText) {
      updateText(newText);
    });
    text = listenService.text;
  }

  updateText(String newText) {
    text = newText;
    textStreamController.sink.add(text);
  }

  clearText() {
    text = "";
    textStreamController.sink.add("");
  }
}
