import 'package:flutter/material.dart';
import 'game_screen.dart';

/// The introduction screen shown when the app starts.
class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'BIG BROTHER',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
                letterSpacing: 8.0,
                shadows: [Shadow(color: Colors.green, blurRadius: 10)],
              ),
            ),
            const Text(
              'SYSTEM INITIALIZATION PROGRAM',
              style: TextStyle(
                fontSize: 16,
                color: Colors.greenAccent,
                letterSpacing: 4.0,
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                // Navigate to the main game screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                child: Text(
                  'ESTABLISH CONNECTION',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
