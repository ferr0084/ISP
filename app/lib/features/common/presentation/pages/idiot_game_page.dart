import 'package:flutter/material.dart';

class IdiotGamePage extends StatelessWidget {
  const IdiotGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Idiot Game'),
      ),
      body: const Center(
        child: Text('Idiot Game Page Content'),
      ),
    );
  }
}