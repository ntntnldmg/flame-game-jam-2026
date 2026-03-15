import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_typography.dart';
import 'consts.dart';
import 'game/game_cubit.dart';
import 'screens/intro_screen.dart';

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
    final ubuntuMonoTheme = GoogleFonts.ubuntuMonoTextTheme().apply(
      fontFamily: AppTypography.ubuntuMonoFamily,
    );
    return BlocProvider(
      create: (_) => GameCubit(),
      child: MaterialApp(
        title: 'Terrorist Threat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.appBackground,
          // Global font for the whole game.
          fontFamily: AppTypography.ubuntuMonoFamily,
          textTheme: ubuntuMonoTheme,
          primaryTextTheme: ubuntuMonoTheme,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.green,
            secondary: AppColors.red,
            surface: AppColors.surface,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: const BeveledRectangleBorder(), // Sharp corners
              side: const BorderSide(color: AppColors.green),
              backgroundColor: AppColors.black,
              foregroundColor: AppColors.green,
              textStyle: AppTypography.mono(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: AppColors.surface,
            shape: BeveledRectangleBorder(
              side: BorderSide(color: AppColors.green, width: 2),
            ),
            titleTextStyle: TextStyle(
              color: AppColors.green,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            contentTextStyle: TextStyle(color: AppColors.green, fontSize: 16),
          ),
        ),
        home: const IntroScreen(),
      ),
    );
  }
}
