import 'package:flutter/material.dart';
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
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(80),
            ),
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
                    builder: (context, state) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () async {
                              if (state.data == ListenState.noPermissions) {
                                listenService.initializeListening();
                              } else if (listenService.stt.isAvailable &&
                                  state.data == ListenState.readyToListen) {
                                listenService.setState(ListenState.listening);
                                listenService.startListening();
                              } else if (listenService.stt.isAvailable &&
                                  state.data == ListenState.listening) {
                                listenService
                                    .setState(ListenState.readyToListen);
                                listenService.stopListening();
                                Future.delayed(
                                    const Duration(milliseconds: 200), () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (buildContext) {
                                      return TextPage(
                                          textService:
                                              TextService(listenService));
                                    }),
                                  );
                                });
                              }
                            },
                            icon: Icon(
                                getIcon(
                                    state.data ?? ListenState.noPermissions),
                                size: 80),
                            padding: const EdgeInsets.all(14),
                          ),
                          if (state.data == ListenState.noPermissions)
                            const SizedBox(
                              height: 10,
                            ),
                          if (state.data == ListenState.noPermissions)
                            Text(
                              "Speech recognition not available. Please check that you have granted this app audio permissions.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red.shade300),
                            ),
                        ],
                      );
                    });
              },
            ),
          ),
        ),
      ),
    );
  }

  IconData getIcon(ListenState state) {
    if (state == ListenState.readyToListen) {
      return Icons.mic;
    } else if (state == ListenState.listening) {
      return Icons.stop;
    } else {
      return Icons.refresh;
    }
  }
}
