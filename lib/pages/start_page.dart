import 'package:flutter/material.dart';
import 'package:writing_help/pages/settings_page.dart';
import 'package:writing_help/pages/text_page.dart';
import 'package:writing_help/services/listen_service.dart';
import 'package:writing_help/services/text_service.dart';

class StartPage extends StatelessWidget {
  final ListenService listenService;

  const StartPage({super.key, required this.listenService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Colors.grey.shade400,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return SettingsPage(
                      settings: listenService.settings,
                      listenService: listenService,
                    );
                  }));
                },
              ),
            ),
            Center(
              child: FutureBuilder(
                future: listenService.initializeListening(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(),
                    );
                  }
                  return StreamBuilder<ListenState>(
                    stream: listenService.stateStream,
                    initialData: listenService.state,
                    builder: (context, stateSnapshot) {
                      ListenState? state = stateSnapshot.data;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(80),
                            ),
                            child: IconButton(
                              onPressed: () async {
                                if (state == ListenState.noPermissions) {
                                  listenService.initializeListening();
                                } else if (listenService.stt.isAvailable &&
                                    state == ListenState.readyToListen) {
                                  listenService.setState(ListenState.listening);
                                  listenService.startListening();
                                } else if (listenService.stt.isAvailable &&
                                    state == ListenState.listening) {
                                  listenService
                                      .setState(ListenState.readyToListen);
                                  listenService.stopListening();
                                  Future.delayed(
                                      const Duration(milliseconds: 200), () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (buildContext) {
                                        return TextPage(
                                          textService:
                                              TextService(listenService),
                                        );
                                      }),
                                    );
                                  });
                                }
                              },
                              icon: Icon(
                                  getIcon(state ?? ListenState.noPermissions),
                                  size: 80),
                              padding: const EdgeInsets.all(14),
                            ),
                          ),
                          if (state == ListenState.noPermissions ||
                              state == ListenState.error)
                            const SizedBox(
                              height: 10,
                            ),
                          if (state == ListenState.noPermissions)
                            Text(
                              "Speech recognition not available. Please check that you have granted this app audio permissions.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red.shade300),
                            ),
                          if (state == ListenState.error)
                            Text(
                              listenService.error,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red.shade300),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData getIcon(ListenState state) {
    if (state == ListenState.readyToListen) {
      return Icons.mic;
    } else if (state == ListenState.listening) {
      return Icons.stop;
    } else if (state == ListenState.noPermissions) {
      return Icons.refresh;
    } else {
      return Icons.error;
    }
  }
}
