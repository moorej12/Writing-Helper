import 'package:flutter/material.dart';

class TextPage extends StatelessWidget {
  final String text;

  const TextPage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Text(text),
    ));
  }
}
