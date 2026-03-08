import 'package:bigbrother/game/game_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ui/intro_screen.dart';

void main() {
  runApp(const BigBrotherApp());
}

/// The root application widget.
class BigBrotherApp extends StatelessWidget {
  const BigBrotherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameCubit(),
      child: MaterialApp(
        title: 'Big Brother Game',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          fontFamily: 'monospace', // Gives the brutalist terminal feel
          colorScheme: const ColorScheme.dark(
            primary: Colors.greenAccent,
            secondary: Colors.redAccent,
            surface: Color(0xFF111111),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: const BeveledRectangleBorder(), // Sharp corners
              side: const BorderSide(color: Colors.greenAccent),
              backgroundColor: Colors.black,
              foregroundColor: Colors.greenAccent,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: Color(0xFF111111),
            shape: BeveledRectangleBorder(
              side: BorderSide(color: Colors.greenAccent, width: 2),
            ),
            titleTextStyle: TextStyle(
              color: Colors.greenAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
            contentTextStyle: TextStyle(
              color: Colors.greenAccent,
              fontSize: 16,
              fontFamily: 'monospace',
            ),
          ),
        ),
        home: const IntroScreen(),
      ),
    );
  }
}
