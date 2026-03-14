import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../consts.dart';
import '../game/game_cubit.dart';

/// Full-screen CCTV surveillance overlay.
///
/// Shows a grid of faces (circles). After a short scan period one random face
/// turns red. Player must tap it within [Consts.cctvClickWindowSeconds] seconds.
/// Resolves the event via [GameCubit.resolveCctvEvent].
class CCTVOverlay extends StatefulWidget {
  const CCTVOverlay({super.key});

  @override
  State<CCTVOverlay> createState() => _CCTVOverlayState();
}

class _CCTVOverlayState extends State<CCTVOverlay>
    with SingleTickerProviderStateMixin {
  static final Random _random = Random();

  final int _faceCount = Consts.cctvFaceCount;
  late int _targetIndex;
  bool _targetVisible = false;
  bool _resolved = false;

  // Countdown bar for the click window
  late AnimationController _timerController;
  Timer? _scanDelayTimer;
  Timer? _windowTimer;

  @override
  void initState() {
    super.initState();
    _targetIndex = _random.nextInt(_faceCount);

    _timerController =
        AnimationController(
          vsync: this,
          duration: Duration(
            milliseconds: (Consts.cctvClickWindowSeconds * 1000).toInt(),
          ),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && !_resolved) {
            _resolve(success: false);
          }
        });

    // Short initial scan before target turns red.
    _scanDelayTimer = Timer(
      Duration(milliseconds: (Consts.cctvInitialScanSeconds * 1000).toInt()),
      () {
        if (!mounted) return;
        setState(() => _targetVisible = true);
        _timerController.forward();
        // Auto-fail when window expires.
        _windowTimer = Timer(
          Duration(
            milliseconds: (Consts.cctvClickWindowSeconds * 1000).toInt(),
          ),
          () => _resolve(success: false),
        );
      },
    );
  }

  @override
  void dispose() {
    _scanDelayTimer?.cancel();
    _windowTimer?.cancel();
    _timerController.dispose();
    super.dispose();
  }

  void _resolve({required bool success}) {
    if (_resolved) return;
    _resolved = true;
    _scanDelayTimer?.cancel();
    _windowTimer?.cancel();
    if (mounted) {
      context.read<GameCubit>().resolveCctvEvent(success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: AppColors.cctvScrim,
        child: Column(
          children: [
            // Header bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.black,
                border: const Border(
                  bottom: BorderSide(color: AppColors.green, width: 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CCTV // SECTOR 7 LIVE FEED',
                    style: TextStyle(
                      color: AppColors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'REC',
                        style: TextStyle(
                          color: AppColors.red,
                          fontSize: 13,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scanline instruction
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _targetVisible
                    ? 'THREAT DETECTED — TAP TO NEUTRALISE'
                    : 'SCANNING CROWD...',
                style: TextStyle(
                  color: _targetVisible ? AppColors.red : AppColors.textMuted,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
            ),

            // Click-window countdown bar — visible only once target is live.
            if (_targetVisible)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: AnimatedBuilder(
                  animation: _timerController,
                  builder: (_, _) => LinearProgressIndicator(
                    value: 1.0 - _timerController.value,
                    backgroundColor: AppColors.textDisabled,
                    valueColor: AlwaysStoppedAnimation(
                      _timerController.value > 0.6
                          ? AppColors.red
                          : AppColors.green,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // CCTV face grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 120,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                  ),
                  itemCount: _faceCount,
                  itemBuilder: (_, index) {
                    final isTarget = index == _targetIndex && _targetVisible;
                    return GestureDetector(
                      onTap: isTarget ? () => _resolve(success: true) : null,
                      child: _FaceCell(isTarget: isTarget),
                    );
                  },
                ),
              ),
            ),

            // Static noise footer label
            Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 12),
              child: Text(
                'MINISTRY OF SECURITY — INTERNAL NETWORK //  AUTHORISED ONLY',
                style: TextStyle(
                  color: AppColors.textLowEmphasis,
                  fontSize: 11,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single face cell rendered as a green-boxed circle.
/// Turns red and pulses when it is the target.
class _FaceCell extends StatefulWidget {
  final bool isTarget;
  const _FaceCell({required this.isTarget});

  @override
  State<_FaceCell> createState() => _FaceCellState();
}

class _FaceCellState extends State<_FaceCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boxColor = widget.isTarget ? AppColors.red : AppColors.green;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, _) {
        final opacity = widget.isTarget ? (0.5 + 0.5 * _pulse.value) : 1.0;
        return Opacity(
          opacity: opacity,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: boxColor, width: 2),
            ),
            child: Center(
              child: CustomPaint(
                painter: _FacePainter(boxColor: boxColor),
                size: const Size(60, 60),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Paints a simple circle face with dots for eyes and a curved line for a mouth.
class _FacePainter extends CustomPainter {
  final Color boxColor;
  _FacePainter({required this.boxColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = boxColor.withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;

    // Head
    canvas.drawCircle(Offset(cx, cy), r, paint);

    // Eyes
    final eyePaint = Paint()
      ..color = boxColor.withAlpha(220)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - r * 0.35, cy - r * 0.2), r * 0.12, eyePaint);
    canvas.drawCircle(Offset(cx + r * 0.35, cy - r * 0.2), r * 0.12, eyePaint);

    // Mouth
    final mouth = Rect.fromCenter(
      center: Offset(cx, cy + r * 0.25),
      width: r * 0.7,
      height: r * 0.35,
    );
    canvas.drawArc(mouth, 0, pi, false, paint);
  }

  @override
  bool shouldRepaint(_FacePainter old) => old.boxColor != boxColor;
}
