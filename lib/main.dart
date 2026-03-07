import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bigbrother/home_screen.dart';

class BigBrotherApp extends StatelessWidget {
  const BigBrotherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    	title: 'Big Brother',
    	debugShowCheckedModeBanner: false,
    	theme: ThemeData(
    		textTheme: GoogleFonts.notoSansTextTheme(),
    	),
      home: HomeScreen(),
    );
  }
}

void main() => runApp(const BigBrotherApp());

