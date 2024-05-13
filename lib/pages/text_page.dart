import 'package:flutter/material.dart';
import 'package:writing_help/services/text_service.dart';

class TextPage extends StatelessWidget {
  final TextService textService;

  const TextPage({super.key, required this.textService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(children: [
            SingleChildScrollView(
              child: StreamBuilder<String>(
                stream: textService.textStream,
                initialData: textService.text,
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 40),
                    child: Text(
                      snapshot.data ?? "",
                      style: const TextStyle(fontSize: 24),
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5),
                    ),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
