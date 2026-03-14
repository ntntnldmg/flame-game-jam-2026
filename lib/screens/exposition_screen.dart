import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_typography.dart';
import '../game/game_cubit.dart';
import 'game_screen.dart';

class ExpositionScreen extends StatefulWidget {
  const ExpositionScreen({super.key});

  @override
  State<ExpositionScreen> createState() => _ExpositionScreenState();
}

class _ExpositionScreenState extends State<ExpositionScreen> {
  int _pageIndex = 0;

  static const List<_ExpositionPageData> _pages = [
    _ExpositionPageData(
      title: 'STATE OF THE NATION // YEAR 2049',
      body:
          'After twelve consecutive years of bombings and coordinated cyber '
          'sabotage, civilian trust has collapsed. Infrastructure runs under '
          'military emergency protocols, and every district is now divided into '
          'surveillance sectors.\n\n'
          'Your command center receives fragmented intelligence, incomplete '
          'witness reports, and manipulated public data. Every decision must be '
          'made under pressure, before the next incident unfolds.',
    ),
    _ExpositionPageData(
      title: 'YOUR MANDATE',
      body:
          'You are assigned to the Internal Stability Bureau to identify and '
          'neutralize active threats hidden among ordinary residents.\n\n'
          'Investigate patterns, issue arrests with care, and deploy wire taps '
          'strategically. Wrong actions fuel panic and political backlash. '
          'Delay gives hostile networks time to regroup.\n\n'
          'There is no perfect information. Only consequences.',
    ),
  ];

  bool get _isLastPage => _pageIndex == _pages.length - 1;

  void _startGame() {
    context.read<GameCubit>().startNewSimulation();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const GameScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_pageIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF080B08),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFF0F1D10), const Color(0xFF070907)],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 100),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color(0xCC000000),
                        border: Border.all(
                          color: Colors.greenAccent.withAlpha(180),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x5500FF66),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CLASSIFIED BRIEFING',
                            style: AppTypography.mono(
                              color: Colors.greenAccent,
                              fontSize: 20,
                              letterSpacing: 2.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(height: 2, color: Colors.greenAccent),
                          const SizedBox(height: 26),
                          Text(
                            page.title,
                            style: AppTypography.mono(
                              color: Colors.white,
                              fontSize: 38,
                              letterSpacing: 1.6,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                page.body,
                                style: AppTypography.mono(
                                  color: Colors.white70,
                                  fontSize: 24,
                                  letterSpacing: 0.6,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: List.generate(
                              _pages.length,
                              (index) => Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(right: 8),
                                color: index == _pageIndex
                                    ? Colors.greenAccent
                                    : Colors.white24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_isLastPage) {
                                  _startGame();
                                  return;
                                }
                                setState(() => _pageIndex += 1);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 12,
                                ),
                                child: Text(
                                  _isLastPage ? 'BEGIN OPERATION' : 'NEXT',
                                  style: AppTypography.mono(
                                    fontSize: 18,
                                    letterSpacing: 1.6,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: Center(
                child: TextButton(
                  onPressed: _startGame,
                  child: Text(
                    'SKIP EXPOSITION',
                    style: AppTypography.mono(
                      color: Colors.white70,
                      fontSize: 16,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpositionPageData {
  final String title;
  final String body;

  const _ExpositionPageData({required this.title, required this.body});
}
