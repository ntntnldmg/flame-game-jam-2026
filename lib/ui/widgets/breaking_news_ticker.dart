import 'dart:math';

import 'package:flutter/material.dart';

import '../../app_typography.dart';
import '../../consts.dart';
import '../../game_script.dart';

class BreakingNewsTicker extends StatefulWidget {
  final int day;

  const BreakingNewsTicker({super.key, required this.day});

  @override
  State<BreakingNewsTicker> createState() => _BreakingNewsTickerState();
}

class _BreakingNewsTickerState extends State<BreakingNewsTicker>
    with SingleTickerProviderStateMixin {
  static final Random _random = Random();

  late final AnimationController _controller;
  late List<String> _gameplayBulletins;

  static const double _height = 40;
  int _currentHeadlineIndex = 0;

  @override
  void initState() {
    super.initState();
    _gameplayBulletins = _buildGameplayBulletinsForDay(widget.day);

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 24))
          ..addStatusListener((status) {
            if (status != AnimationStatus.completed || !mounted) return;
            setState(() {
              _currentHeadlineIndex =
                  (_currentHeadlineIndex + 1) % _gameplayBulletins.length;
            });
          })
          ..repeat();
  }

  @override
  void didUpdateWidget(covariant BreakingNewsTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.day == widget.day) return;

    setState(() {
      _currentHeadlineIndex = 0;
      _gameplayBulletins = _buildGameplayBulletinsForDay(widget.day);
    });

    _controller
      ..reset()
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tickerText = _gameplayBulletins[_currentHeadlineIndex].toUpperCase();

    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: AppColors.breakingNewsBackground,
        border: Border(top: BorderSide(color: AppColors.green.withAlpha(180))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: AppColors.green.withAlpha(26),
            alignment: Alignment.center,
            child: Text(
              'BREAKING NEWS',
              style: AppTypography.mono(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                height: 1.0,
              ),
              maxLines: 1,
              softWrap: false,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final style = AppTypography.mono(
                  color: AppColors.textPrimary,
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  height: 1.0,
                );
                final textWidth = _measureWidth(tickerText, style);
                final loopWidth = textWidth + 120;

                return ClipRect(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final dx = -_controller.value * loopWidth;
                      return Transform.translate(
                        offset: Offset(dx, 0),
                        child: OverflowBox(
                          alignment: Alignment.centerLeft,
                          minWidth: 0,
                          maxWidth: double.infinity,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _TickerText(text: tickerText, style: style),
                              const SizedBox(width: 120),
                              _TickerText(text: tickerText, style: style),
                              const SizedBox(width: 120),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _measureWidth(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  List<String> _buildGameplayBulletinsForDay(int day) {
    final dayBulletins = List<String>.from(GameScript.newsBulletins[day] ?? []);

    if (dayBulletins.isEmpty) {
      return const ['No news available at this time.'];
    }

    final count = 5 + _random.nextInt(2); // 5..6
    final selected = List<String>.from(dayBulletins)..shuffle(_random);

    return selected
        .take(min(count, selected.length))
        .map(_resolvePlaceholders)
        .toList(growable: false);
  }

  String _resolvePlaceholders(String text) {
    final firstName = _pickAny([
      ...GameScript.maleFirstNames,
      ...GameScript.femaleFirstNames,
    ]);
    final lastName = _pickAny(GameScript.lastNames);
    final district = _pickAny(GameScript.districtNames);
    final age = (18 + _random.nextInt(53)).toString();

    return text
        .replaceAll(GameScript.firstNameStandin, firstName)
        .replaceAll(GameScript.lastNameStandin, lastName)
        .replaceAll(GameScript.districtStandin, district)
        .replaceAll(GameScript.ageStandin, age);
  }

  String _pickAny(List<String> values) {
    return values[_random.nextInt(values.length)];
  }
}

class _TickerText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _TickerText({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.clip,
    );
  }
}
