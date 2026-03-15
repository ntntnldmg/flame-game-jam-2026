import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_typography.dart';
import '../audio/audio_settings.dart';
import '../consts.dart';
import '../game/game_cubit.dart';
import '../game/game_state.dart';

class GameOverOverlay extends StatefulWidget {
  const GameOverOverlay({super.key});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  bool _isVisible = false;
  bool _showStats = false;
  dynamic _gameOverPlayer;

  @override
  void initState() {
    super.initState();
    _playGameOverAudioOnce();

    Future.microtask(() {
      if (!mounted) return;
      setState(() => _isVisible = true);
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _showStats = true);
    });
  }

  @override
  void dispose() {
    _stopGameOverAudio();
    super.dispose();
  }

  Future<void> _playGameOverAudioOnce() async {
    if (!AudioSettings.isEnabled) return;
    try {
      await FlameAudio.bgm.stop();
      _gameOverPlayer = await FlameAudio.play('gameover.ogg');
    } catch (error) {
      debugPrint('Game over audio unavailable: $error');
      _gameOverPlayer = null;
    }
  }

  Future<void> _stopGameOverAudio() async {
    try {
      await _gameOverPlayer?.stop();
    } catch (_) {}
    _gameOverPlayer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: AnimatedOpacity(
        opacity: _isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 800),
        child: Container(
          color: AppColors.gameOverScrim,
          child: Center(
            child: BlocBuilder<GameCubit, GameState>(
              buildWhen: (previous, current) =>
                  previous.isTrueEnding != current.isTrueEnding ||
                  previous.currentDay != current.currentDay ||
                  previous.arrestCount != current.arrestCount ||
                  previous.investigationCount != current.investigationCount,
              builder: (context, state) {
                final isTrueEnding = state.isTrueEnding;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isTrueEnding ? 'THE END' : 'CRIME PARADOX',
                      style: AppTypography.mono(
                        color: AppColors.red,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (!isTrueEnding && _showStats) ...[
                      Text(
                        'Days Survived: ${state.currentDay}',
                        style: AppTypography.mono(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total Arrests: ${state.arrestCount}',
                        style: AppTypography.mono(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Investigations Performed: ${state.investigationCount}',
                        style: AppTypography.mono(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<GameCubit>().restartSimulation(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          child: Text(
                            'RESTART SIMULATION',
                            style: AppTypography.mono(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
