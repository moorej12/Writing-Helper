import 'package:flutter/material.dart';
import 'package:writing_help/services/listen_service.dart';
import 'package:writing_help/services/settings_service.dart';

class SettingsPage extends StatelessWidget {
  final SettingsService settings;
  final ListenService listenService;

  const SettingsPage(
      {super.key, required this.settings, required this.listenService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Text(
              "Please choose a language",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            StreamBuilder<LocaleOption>(
              stream: settings.localeStream,
              builder: (context, currentLocaleSnapshot) {
                return StreamBuilder<List<LocaleOption>>(
                  stream: settings.localeListStream,
                  builder: (context, listSnapshot) {
                    if (settings.localesAvailable.isNotEmpty &&
                        settings.currentLocale != null) {
                      return Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) => ListTile(
                            title: Align(
                              alignment: Alignment.center,
                              child: Text(
                                settings.localesAvailable[index].name,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            subtitle: getLocaleMessage(index),
                            onTap: () {
                              if (settings.localesAvailable[index].isWorking) {
                                listenService
                                    .setState(ListenState.readyToListen);
                                settings.setLocale(
                                    settings.localesAvailable[index]);
                                listenService.testCurrentLocale();
                              }
                            },
                          ),
                          itemCount: settings.localesAvailable.length,
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget? getLocaleMessage(int index) {
    if (!settings.localesAvailable[index].isWorking) {
      return const Align(
        alignment: Alignment.center,
        child: Text("Not Available"),
      );
    } else if (isCurrentLocale(index)) {
      return const Align(
        alignment: Alignment.center,
        child: Text("Selected"),
      );
    } else {
      return null;
    }
  }

  bool isCurrentLocale(int index) {
    print(
        "${settings.localesAvailable[index].id} : ${settings.currentLocale?.id}");
    return settings.localesAvailable[index].id == settings.currentLocale?.id;
  }
}
