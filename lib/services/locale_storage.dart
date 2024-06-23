import 'package:shared_preferences/shared_preferences.dart';

class LocaleStorage {
  final _prefLangKey = "lastSavedLang";

  Future<String?> getStoredLanguage() async {
    SharedPreferences prefsStorage = await SharedPreferences.getInstance();
    String? storedLang = prefsStorage.getString(_prefLangKey);
    return storedLang;
  }

  Future<void> storeLang(String langCode) async {
    SharedPreferences prefsStorage = await SharedPreferences.getInstance();
    prefsStorage.setString(_prefLangKey, langCode);
  }
}
