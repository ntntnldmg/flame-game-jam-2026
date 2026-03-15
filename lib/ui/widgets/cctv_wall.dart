import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../game/game_state.dart';
import 'cctv_screen_tile.dart';

class CctvWall extends StatefulWidget {
  final GameState state;

  const CctvWall({required this.state, super.key});

  @override
  State<CctvWall> createState() => _CctvWallState();
}

class _CctvWallState extends State<CctvWall> {
  static final Random _random = Random();

  static const double _spacing = 0;
  static const double _tileAspectRatio = 16 / 9;
  static const _baseDate = (year: 2064, month: 4, day: 18);
  static const _feeds = [
    ('assets/images/cam1.png', 1),
    ('assets/images/cam2.png', 2),
    ('assets/images/cam3.png', 3),
    ('assets/images/cam4.png', 4),
  ];

  final DateTime _mountedAt = DateTime.now();
  late final DateTime _cameraStartTime;
  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _cameraStartTime = _randomStartTime();
    _ticker = Timer.periodic(const Duration(milliseconds: 10), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  DateTime _randomStartTime() {
    final hour = 10 + _random.nextInt(8); // 10..17
    final minute = _random.nextInt(60);
    final second = _random.nextInt(60);
    final millisecond = _random.nextInt(1000);
    return DateTime(
      _baseDate.year,
      _baseDate.month,
      _baseDate.day,
      hour,
      minute,
      second,
      millisecond,
    );
  }

  String _timestampForCamera(int index) {
    final elapsed = _now.difference(_mountedAt);
    final time = _cameraStartTime.add(elapsed);
    final yyyy = time.year.toString().padLeft(4, '0');
    final dd = (time.day + widget.state.currentDay - 1).toString().padLeft(
      2,
      '0',
    );
    final mm = time.month.toString().padLeft(2, '0');
    final hh = time.hour.toString().padLeft(2, '0');
    final min = time.minute.toString().padLeft(2, '0');
    final ss = time.second.toString().padLeft(2, '0');
    final ms = time.millisecond.toString().padLeft(3, '0');
    return '$dd-$mm-$yyyy $hh:$min:$ss.$ms';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 2;
        final rows = (_feeds.length / columns).ceil();

        final tileWidthByWidth =
            (constraints.maxWidth - (_spacing * (columns - 1))) / columns;
        final tileWidthByHeight =
            ((constraints.maxHeight - (_spacing * (rows - 1))) / rows) *
            _tileAspectRatio;
        final tileWidth = min(tileWidthByWidth, tileWidthByHeight);
        final tileHeight = tileWidth / _tileAspectRatio;

        final wallWidth = (tileWidth * columns) + (_spacing * (columns - 1));
        final wallHeight = (tileHeight * rows) + (_spacing * (rows - 1));

        return Center(
          child: SizedBox(
            width: wallWidth,
            height: wallHeight,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _feeds.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: _spacing,
                crossAxisSpacing: _spacing,
                childAspectRatio: _tileAspectRatio,
              ),
              itemBuilder: (context, index) {
                return CctvScreenTile(
                  cameraNumber: _feeds[index].$2,
                  imageAsset: _feeds[index].$1,
                  timestamp: _timestampForCamera(index),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
