import 'dart:async';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:writing_help/services/settings_service.dart';

enum ListenState { readyToListen, listening, noPermissions, error }

class ListenService {
  SettingsService settings;
  ListenState state = ListenState.readyToListen;
  String error = "";
  String text = "";
  SpeechToText stt = SpeechToText();
  String? localeInTesting;

  StreamController<ListenState> stateStreamController =
      StreamController.broadcast();
  Stream<ListenState> get stateStream => stateStreamController.stream;
  StreamController<String> textStreamController = StreamController.broadcast();
  Stream<String> get textStream => textStreamController.stream;

  ListenService(this.settings) {
    // initializeListening();
  }

  startListening() async {
    error = "";
    stt.listen(
      onResult: (SpeechRecognitionResult result) {
        if (result.finalResult && result.alternates.isNotEmpty) {
          text = "$text ${result.alternates[0].recognizedWords}";
          textStreamController.sink.add(text);
          text = "";
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
      localeId: settings.currentLocale?.code,
    );
  }

  Future<bool> initializeListening() async {
    await setLocaleList();
    setInitialDivider();
    await setInitialLocale();
    print(stt.isAvailable);
    bool result = await stt.initialize(
        onError: (speechRecognitionError) {
          error = speechRecognitionError.errorMsg;
          if (error.contains("error_language_not_supported")) {
            print("language not supported");
            LocaleOption? locale = settings.currentLocale;
            if (locale == null) {
              return;
            }
            if (!locale.doubleTested) {
              print("trying other divider");
              locale.doubleTested = true;
              updateLocaleDividerAndTestAgain(locale);
            } else {
              setState(ListenState.error);
              print("language completely not supported");
              error =
                  "Unable to use current language. Please select a different language in the settings.";
              markCurrentLocaleNotAvailable();
            }
          } else if (error.contains("server_disconnected")) {
            print(speechRecognitionError);
            //initializeListening();
          }
        },
        debugLogging: false);
    if (result == false) {
      setState(ListenState.noPermissions);
    } else {
      setState(ListenState.readyToListen);
    }
    await testCurrentLocale();
    return true;
  }

  setLocaleList() async {
    List<LocaleName> localeNames = await stt.locales();
    int id = 0;
    List<LocaleOption> locales =
        localeNames.map((e) => LocaleOption(e.localeId, e.name, id++)).toList();
    settings.updateLocaleList(locales);
  }

  setInitialDivider() {
    LocaleOption? option = settings.localesAvailable.firstOrNull;
    if (option != null) {
      String divider = option.code.substring(2, 3);
      settings.divider = divider;
    }
  }

  setInitialLocale() async {
    String initialCode = await settings.getStoredLocaleCode();
    if (initialCode.isEmpty ||
        settings.localesAvailable.indexWhere(
                (element) => element.code == swapDivider(initialCode)) ==
            -1) {
      initialCode = (await stt.systemLocale())?.localeId ?? "";
    }
    if (initialCode.isNotEmpty) {
      if (initialCode.substring(2, 3) != settings.divider) {
        String updatedCode = swapDivider(initialCode);
        settings.currentLocale = settings.localesAvailable
            .firstWhere((element) => element.code == updatedCode);
      } else {
        settings.currentLocale = settings.localesAvailable
            .firstWhere((element) => element.code == initialCode);
      }
    }
  }

  String swapDivider(String code) {
    return code.replaceFirst(code.substring(2, 3), settings.divider);
  }

  updateLocaleDividerAndTestAgain(LocaleOption locale) {
    print("trying something different");
    settings.toggleLocaleDivider();
    settings.updateLocaleListDividers();
    locale = settings.convertLocaleToCurrentDivider(locale);
    settings.setLocale(locale);
    testCurrentLocale();
  }

  testCurrentLocale() async {
    localeInTesting =
        settings.currentLocale?.code ?? (await stt.systemLocale())?.localeId;
    print(localeInTesting);
    if (localeInTesting != null) {
      print("testing $localeInTesting");
      stt.listen(
        onResult: (SpeechRecognitionResult result) {},
        listenOptions: SpeechListenOptions(
          autoPunctuation: true,
          listenMode: ListenMode.dictation,
          onDevice: true,
        ),
        localeId: localeInTesting,
      );
      await Future.delayed(const Duration(milliseconds: 200));
      await stt.stop();
      localeInTesting = null;
    }
  }

  markCurrentLocaleNotAvailable() {
    if (settings.currentLocale != null) {
      settings.currentLocale!.isWorking = false;
      settings.updateLocaleList(settings.localesAvailable);
    } else {
      print("Error - no current locale");
    }
  }

  void setState(ListenState newState) {
    state = newState;
    stateStreamController.sink.add(state);
  }

  void stopListening() {
    stt.stop();
  }
}
