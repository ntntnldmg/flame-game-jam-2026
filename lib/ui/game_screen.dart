import 'package:bigbrother/consts.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../audio/audio_settings.dart';
import '../game/big_brother_game.dart';
import '../game/game_cubit.dart';
import '../game/game_state.dart';
import 'day_counter_widget.dart';
import 'intro_screen.dart';
import 'resident_panel.dart';
import 'cctv_overlay.dart';
import 'intelligence_report_overlay.dart';
import 'news_report_overlay.dart';

/// The main screen where the game is rendered.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // GameCubit is provided at the app root (main.dart) so that state —
    // including residents — persists even when navigating back to IntroScreen.
    return const _GameScreenContent();
  }
}

class _GameScreenContent extends StatefulWidget {
  const _GameScreenContent();

  @override
  State<_GameScreenContent> createState() => _GameScreenContentState();
}

class _GameScreenContentState extends State<_GameScreenContent> {
  late final BigBrotherGame _game;
  bool _isGameplayMusicActive = false;
  int _gameplayMusicRequestId = 0;

  @override
  void initState() {
    super.initState();
    // Initialize the Flame game instance, passing the cubit
    _game = BigBrotherGame(context.read<GameCubit>());
    _syncGameplayMusic(context.read<GameCubit>().state);
  }

  @override
  void dispose() => super.dispose();

  Future<void> _startGameplayMusic() async {
    if (_isGameplayMusicActive) return;
    if (!AudioSettings.isEnabled) return;
    final requestId = ++_gameplayMusicRequestId;

    Future<bool> tryPlayOnce() async {
      await FlameAudio.bgm.stop();
      await FlameAudio.bgm.play('gameplay.ogg');
      return true;
    }

    try {
      await tryPlayOnce();
      _isGameplayMusicActive = true;
    } catch (error) {
      if (error.toString().contains('AbortError')) {
        await Future.delayed(const Duration(milliseconds: 220));
        if (!mounted || requestId != _gameplayMusicRequestId) {
          _isGameplayMusicActive = false;
          return;
        }
        try {
          await tryPlayOnce();
          _isGameplayMusicActive = true;
          return;
        } catch (_) {
          // Fall through to generic handler below.
        }
      }
      debugPrint('Gameplay music unavailable: $error');
      _isGameplayMusicActive = false;
    }
  }

  Future<void> _stopGameplayMusic() async {
    if (!_isGameplayMusicActive) return;
    await FlameAudio.bgm.stop();
    _isGameplayMusicActive = false;
  }

  void _syncGameplayMusic(GameState state) {
    final shouldPlay =
        AudioSettings.isEnabled && state.hasStartedGame && !state.isGameOver;
    if (shouldPlay) {
      _startGameplayMusic();
    } else {
      _stopGameplayMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameCubit, GameState>(
      listenWhen: (previous, current) =>
          previous.hasStartedGame != current.hasStartedGame ||
          previous.isGameOver != current.isGameOver,
      listener: (_, state) => _syncGameplayMusic(state),
      child: Scaffold(
        // appBar: AppBar(),
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // The Flame game widget (transparent background)
            Positioned.fill(child: GameWidget(game: _game)),

            // Left side resident panel — inset from all edges
            const Positioned(
              top: 14,
              bottom: 14,
              left: 14,
              child: ResidentPanel(),
            ),

            // Top left controls
            Positioned(
              top: 20,
              left: 326, // right of panel (14 offset + 290 width + 22 gap)
              child: IconButton(
                icon: const Icon(
                  Icons.power_settings_new,
                  color: Colors.greenAccent,
                ),
                tooltip: 'Terminate Session',
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await _stopGameplayMusic();
                  if (!mounted) return;
                  // Return to the intro screen
                  navigator.pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const IntroScreen(),
                    ),
                  );
                },
              ),
            ),

            // Top right HUD — also listens for a pending intelligence report
            // and shows it as a proper full-screen overlay (dialog).
            Positioned(
              top: 20,
              right: 20,
              child: BlocConsumer<GameCubit, GameState>(
                listenWhen: (previous, current) =>
                    (!previous.isGameOver && current.isGameOver) ||
                    (!previous.isNewsReportPending &&
                        current.isNewsReportPending) ||
                    (!previous.isReportPending && current.isReportPending) ||
                    (!previous.isCctvEventPending &&
                        current.isCctvEventPending),
                listener: (context, state) {
                  if (state.isGameOver) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      barrierColor: Colors.transparent,
                      builder: (dialogContext) => BlocProvider.value(
                        value: context.read<GameCubit>(),
                        child: BlocListener<GameCubit, GameState>(
                          listenWhen: (previous, current) =>
                              previous.isGameOver && !current.isGameOver,
                          listener: (_, _) => Navigator.of(dialogContext).pop(),
                          child: const _GameOverOverlay(),
                        ),
                      ),
                    );
                    return;
                  }
                  if (state.isCctvEventPending) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      barrierColor: Colors.transparent,
                      builder: (dialogContext) => BlocProvider.value(
                        value: context.read<GameCubit>(),
                        child: BlocListener<GameCubit, GameState>(
                          listenWhen: (previous, current) =>
                              previous.isCctvEventPending &&
                              !current.isCctvEventPending,
                          listener: (_, _) => Navigator.of(dialogContext).pop(),
                          child: const CCTVOverlay(),
                        ),
                      ),
                    );
                    return;
                  }
                  if (state.isNewsReportPending &&
                      state.currentNewsReport != null) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      barrierColor: Colors.transparent,
                      builder: (dialogContext) => BlocProvider.value(
                        value: context.read<GameCubit>(),
                        child: BlocListener<GameCubit, GameState>(
                          listenWhen: (previous, current) =>
                              previous.isNewsReportPending &&
                              !current.isNewsReportPending,
                          listener: (_, _) => Navigator.of(dialogContext).pop(),
                          child: NewsReportOverlay(
                            report: state.currentNewsReport!,
                          ),
                        ),
                      ),
                    );
                    return;
                  }

                  if (state.isReportPending && state.currentReport != null) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      barrierColor: Colors.transparent,
                      builder: (dialogContext) => BlocProvider.value(
                        value: context.read<GameCubit>(),
                        child: BlocListener<GameCubit, GameState>(
                          listenWhen: (previous, current) =>
                              previous.isReportPending &&
                              !current.isReportPending,
                          listener: (_, _) => Navigator.of(dialogContext).pop(),
                          child: IntelligenceReportOverlay(
                            report: state.currentReport!,
                          ),
                        ),
                      ),
                    );
                  }
                },
                buildWhen: (previous, current) =>
                    previous.currentDay != current.currentDay ||
                    (previous.remainingTimeInDay * 10).round() !=
                        (current.remainingTimeInDay * 10).round() ||
                    (previous.terroristThreat * 10).toInt() !=
                        (current.terroristThreat * 10).toInt(),
                builder: (context, state) {
                  final dayProgress =
                      1.0 -
                      (state.remainingTimeInDay / Consts.dayDuration).clamp(
                        0.0,
                        1.0,
                      );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DayCounterWidget(
                        day: state.currentDay,
                        dayProgress: dayProgress,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(200),
                          border: Border.all(
                            color:
                                state.terroristThreat >
                                    Consts.threatWarningLevel
                                ? Colors.redAccent
                                : Colors.greenAccent,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          'THREAT: ${state.terroristThreat.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color:
                                state.terroristThreat >
                                    Consts.threatWarningLevel
                                ? Colors.redAccent
                                : Colors.greenAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatefulWidget {
  const _GameOverOverlay();

  @override
  State<_GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<_GameOverOverlay> {
  bool _isVisible = false;
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1 : 0,
      duration: const Duration(milliseconds: 800),
      child: Container(
        color: Colors.black.withAlpha(240),
        child: Center(
          child: BlocBuilder<GameCubit, GameState>(
            buildWhen: (previous, current) =>
                previous.currentDay != current.currentDay ||
                previous.detaineeCount != current.detaineeCount ||
                previous.investigationCount != current.investigationCount,
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "WE'VE WARNED YOU",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (_showStats) ...[
                    Text(
                      'Days Survived: ${state.currentDay}',
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Detainees: ${state.detaineeCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Investigations Performed: ${state.investigationCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<GameCubit>().restartSimulation(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        child: Text(
                          'RESTART SIMULATION',
                          style: TextStyle(fontSize: 20),
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
    );
  }
}
