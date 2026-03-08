import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../game/game_cubit.dart';
import '../models/news_report.dart';

/// Full-screen atmospheric news bulletin shown before intelligence briefing.
class NewsReportOverlay extends StatefulWidget {
  final NewsReport report;

  const NewsReportOverlay({super.key, required this.report});

  @override
  State<NewsReportOverlay> createState() => _NewsReportOverlayState();
}

class _NewsReportOverlayState extends State<NewsReportOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final ms = max(1400, min(6200, widget.report.body.length * 28));
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ms),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(232),
      child: Center(
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: const Color(0xFF020402),
            border: Border.all(color: Colors.greenAccent, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x6600FF66),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'NATIONAL EMERGENCY NETWORK',
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.2,
                    ),
                  ),
                  Text(
                    'DAY ${widget.report.day}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(height: 2, color: Colors.greenAccent),
              const SizedBox(height: 22),
              Text(
                widget.report.headline.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final visibleChars =
                      (widget.report.body.length * _controller.value).floor();
                  final text = widget.report.body.substring(0, visibleChars);
                  return Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.7,
                      letterSpacing: 0.8,
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              Row(
                children: const [
                  Icon(Icons.sensors, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'DETAILS WITHHELD // THREAT CONTINUES',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () =>
                      context.read<GameCubit>().acknowledgeNewsReport(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      'CONTINUE BRIEFING',
                      style: TextStyle(fontSize: 15, letterSpacing: 1.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
