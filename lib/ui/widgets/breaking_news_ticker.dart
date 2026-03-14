import 'package:flutter/material.dart';

import '../../app_typography.dart';
import '../../consts.dart';

class BreakingNewsTicker extends StatefulWidget {
  final String headline;

  const BreakingNewsTicker({super.key, required this.headline});

  @override
  State<BreakingNewsTicker> createState() => _BreakingNewsTickerState();
}

class _BreakingNewsTickerState extends State<BreakingNewsTicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const double _height = 40;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tickerText =
        'BREAKING NEWS   ${widget.headline.toUpperCase()}   BREAKING NEWS   ';

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
