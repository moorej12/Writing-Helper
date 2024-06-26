import 'package:flutter/material.dart';
import 'package:writing_help/pages/start_page.dart';
import 'package:writing_help/services/listen_service.dart';
import 'package:writing_help/services/locale_storage.dart';
import 'package:writing_help/services/settings_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: StartPage(
        listenService: ListenService(SettingsService(LocaleStorage())),
      ),
    );
  }
}
