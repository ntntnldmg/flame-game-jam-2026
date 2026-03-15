import 'package:flame_audio/flame_audio.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../app_typography.dart';
import '../consts.dart';
import '../audio/audio_settings.dart';
import '../game/big_brother_game.dart';
import '../game/game_cubit.dart';
import '../game/game_state.dart';
import 'intro_screen.dart';
import '../ui/widgets/resident_panel.dart';
import '../ui/cctv_overlay.dart';
import '../ui/intelligence_report_overlay.dart';
import '../ui/news_report_overlay.dart';
import '../ui/game_over_overlay.dart';
import '../ui/epilogue_overlay.dart';
import '../ui/widgets/breaking_news_ticker.dart';
import '../ui/widgets/cctv_wall.dart';
import '../ui/widgets/top_status_hud.dart';

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
    final initialState = context.read<GameCubit>().state;
    _syncGameplayMusic(initialState);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _presentPendingOverlay(initialState);
    });
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
        AudioSettings.isEnabled &&
        state.hasStartedGame &&
        !state.isGameOver &&
        !state.isEpiloguePending;
    if (shouldPlay) {
      _startGameplayMusic();
    } else {
      _stopGameplayMusic();
    }
  }

  void _presentPendingOverlay(GameState state) {
    if (!mounted) return;

    if (state.isEpiloguePending) {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: AppColors.transparent,
        builder: (dialogContext) => BlocProvider.value(
          value: context.read<GameCubit>(),
          child: BlocListener<GameCubit, GameState>(
            listenWhen: (previous, current) =>
                previous.isEpiloguePending && !current.isEpiloguePending,
            listener: (_, _) => Navigator.of(dialogContext).pop(),
            child: const EpilogueOverlay(),
          ),
        ),
      );
      return;
    }

    if (state.isGameOver) {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: AppColors.transparent,
        builder: (dialogContext) => BlocProvider.value(
          value: context.read<GameCubit>(),
          child: BlocListener<GameCubit, GameState>(
            listenWhen: (previous, current) =>
                previous.isGameOver && !current.isGameOver,
            listener: (_, _) => Navigator.of(dialogContext).pop(),
            child: const GameOverOverlay(),
          ),
        ),
      );
      return;
    }

    if (state.isCctvEventPending) {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: AppColors.transparent,
        builder: (dialogContext) => BlocProvider.value(
          value: context.read<GameCubit>(),
          child: BlocListener<GameCubit, GameState>(
            listenWhen: (previous, current) =>
                previous.isCctvEventPending && !current.isCctvEventPending,
            listener: (_, _) => Navigator.of(dialogContext).pop(),
            child: const CCTVOverlay(),
          ),
        ),
      );
      return;
    }

    if (state.isNewsReportPending && state.currentNewsReport != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: AppColors.transparent,
        builder: (dialogContext) => BlocProvider.value(
          value: context.read<GameCubit>(),
          child: BlocListener<GameCubit, GameState>(
            listenWhen: (previous, current) =>
                previous.isNewsReportPending && !current.isNewsReportPending,
            listener: (_, _) => Navigator.of(dialogContext).pop(),
            child: NewsReportOverlay(report: state.currentNewsReport!),
          ),
        ),
      );
      return;
    }

    if (state.isReportPending && state.currentReport != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: AppColors.transparent,
        builder: (dialogContext) => BlocProvider.value(
          value: context.read<GameCubit>(),
          child: BlocListener<GameCubit, GameState>(
            listenWhen: (previous, current) =>
                previous.isReportPending && !current.isReportPending,
            listener: (_, _) => Navigator.of(dialogContext).pop(),
            child: IntelligenceReportOverlay(report: state.currentReport!),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameCubit, GameState>(
      listenWhen: (previous, current) =>
          previous.hasStartedGame != current.hasStartedGame ||
          previous.isGameOver != current.isGameOver ||
          previous.isEpiloguePending != current.isEpiloguePending,
      listener: (_, state) => _syncGameplayMusic(state),
      child: Scaffold(
        // appBar: AppBar(),
        body: Stack(
          children: [
            // Background image
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // The Flame game widget (transparent background)
            Positioned.fill(child: GameWidget(game: _game)),

            // Foreground layout in rows for alignment control.
            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 52),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.power_settings_new,
                            color: AppColors.green,
                          ),
                          onPressed: () async {
                            final navigator = Navigator.of(context);
                            await _stopGameplayMusic();
                            if (!mounted) return;
                            navigator.pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const IntroScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: ResidentPanel(),
                        ),
                      ),
                      const SizedBox(width: 22),
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            BlocBuilder<GameCubit, GameState>(
                              buildWhen: (previous, current) =>
                                  previous.currentDay != current.currentDay ||
                                  (previous.remainingTimeInDay * 10).round() !=
                                      (current.remainingTimeInDay * 10)
                                          .round() ||
                                  (previous.terroristThreat * 10).toInt() !=
                                      (current.terroristThreat * 10).toInt() ||
                                  previous.todayResidents !=
                                      current.todayResidents ||
                                  previous.remainingArrestsToday !=
                                      current.remainingArrestsToday ||
                                  previous.remainingInvestigationsToday !=
                                      current.remainingInvestigationsToday ||
                                  previous.remainingWireTapsToday !=
                                      current.remainingWireTapsToday,
                              builder: (context, state) {
                                return TopStatusHud(state: state);
                              },
                            ),
                            const SizedBox(height: 16),
                            const Expanded(child: CctvWall()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: BreakingNewsTicker(
                headline:
                    'Detained father of four claims innocence: "I was only trying to buy a pair of pliers for my garden!"',
              ),
            ),
            
            Positioned(
            	left: 10,
            	bottom: 0,
            	child: Text(
            		'MCTA',
            		style: AppTypography.mono(
                  color: AppColors.green,
                  fontSize: 23,
                  letterSpacing: 0.6,
                  height: 1.5,
                ),
            	),
            ),
            
            Positioned(
            	right: 10,
            	bottom: 0,
            	child: Text(
            		'SMSAIAAASS v.1.0.2.6',
            		style: AppTypography.mono(
                  color: AppColors.green,
                  fontSize: 17,
                  letterSpacing: 0.6,
                  height: 1.5,
                ),
            	),
            ),

            // Gameplay overlays listener (game over, CCTV, reports).
            BlocListener<GameCubit, GameState>(
              listenWhen: (previous, current) =>
                  (!previous.isEpiloguePending && current.isEpiloguePending) ||
                  (!previous.isGameOver && current.isGameOver) ||
                  (!previous.isNewsReportPending &&
                      current.isNewsReportPending) ||
                  (!previous.isReportPending && current.isReportPending) ||
                  (!previous.isCctvEventPending && current.isCctvEventPending),
              listener: (_, state) => _presentPendingOverlay(state),
              child: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
