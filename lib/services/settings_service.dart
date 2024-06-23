import 'dart:async';

import 'package:writing_help/services/locale_storage.dart';

class SettingsService {
  LocaleOption? currentLocale;
  List<LocaleOption> localesAvailable = [];
  String divider = "";
  final LocaleStorage storage;

  StreamController<LocaleOption> localeStreamController =
      StreamController.broadcast();
  Stream<LocaleOption> get localeStream => localeStreamController.stream;

  StreamController<List<LocaleOption>> localeListStreamController =
      StreamController.broadcast();
  Stream<List<LocaleOption>> get localeListStream =>
      localeListStreamController.stream;

  SettingsService(this.storage);

  updateLocaleList(List<LocaleOption> names) {
    print("updatingLocaleList");
    localesAvailable = names;
    localeListStreamController.sink.add(localesAvailable);
  }

  LocaleOption? getFullLocale(String id) {
    try {
      return localesAvailable.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }

  setLocale(LocaleOption locale) {
    print("updatinglocale");
    currentLocale = locale;
    localeStreamController.sink.add(currentLocale!);
    storage.storeLang(currentLocale!.code);
  }

  LocaleOption convertLocaleToCurrentDivider(LocaleOption locale) {
    locale.code = locale.code.replaceAll(RegExp("[-_]"), divider);
    return locale;
  }

  toggleLocaleDivider() {
    if (divider == "-") {
      divider = "_";
    } else {
      divider = "-";
    }
  }

  updateLocaleListDividers() {
    localesAvailable = localesAvailable.map((e) {
      convertLocaleToCurrentDivider(e);
      return e;
    }).toList();
  }

  Future<String> getStoredLocaleCode() async {
    String? storedLocale = await storage.getStoredLanguage();
    return storedLocale ?? "";
  }
}

class LocaleOption {
  final int id;
  String code;
  final String name;
  bool isWorking = true;
  bool doubleTested = false;

  LocaleOption(this.code, this.name, this.id);
}
