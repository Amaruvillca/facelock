import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Screen'),
            ElevatedButton(
              onPressed: () {
                // Navigate to the login screen
                Navigator.of(context).pop();
              },
              child: const Text('Go Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}