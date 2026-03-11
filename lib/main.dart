import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game/game_cubit.dart';
import 'ui/intro_screen.dart';

void main() {
  runApp(const BigBrotherApp());
}

/// The root application widget.
class BigBrotherApp extends StatelessWidget {
  const BigBrotherApp({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocProvider here ensures the cubit — and the residents it holds — survive
    // navigation between IntroScreen and GameScreen for the lifetime of the app.
    final ubuntuMonoTheme = GoogleFonts.ubuntuMonoTextTheme();
    return BlocProvider(
      create: (_) => GameCubit(),
      child: MaterialApp(
        title: 'Big Brother Game',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          // Global font for the whole game.
          fontFamily: GoogleFonts.ubuntuMono().fontFamily,
          textTheme: ubuntuMonoTheme,
          primaryTextTheme: ubuntuMonoTheme,
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
          dialogTheme: DialogThemeData(
            backgroundColor: Color(0xFF111111),
            shape: const BeveledRectangleBorder(
              side: BorderSide(color: Colors.greenAccent, width: 2),
            ),
            titleTextStyle: TextStyle(
              color: Colors.greenAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.ubuntuMono().fontFamily,
            ),
            contentTextStyle: TextStyle(
              color: Colors.greenAccent,
              fontSize: 16,
              fontFamily: GoogleFonts.ubuntuMono().fontFamily,
            ),
          ),
        ),
        home: const IntroScreen(),
      ),
    );
  }
}
