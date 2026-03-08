import 'package:bigbrother/consts.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../game/big_brother_game.dart';
import '../game/game_cubit.dart';
import '../game/game_state.dart';
import 'intro_screen.dart';
import 'citizen_panel.dart';
import 'intelligence_report_overlay.dart';
import 'news_report_overlay.dart';

/// The main screen where the game is rendered.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // GameCubit is provided at the app root (main.dart) so that state —
    // including citizens — persists even when navigating back to IntroScreen.
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

  @override
  void initState() {
    super.initState();
    // Initialize the Flame game instance, passing the cubit
    _game = BigBrotherGame(context.read<GameCubit>());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: Stack(
        children: [
          // The Flame game widget
          Positioned.fill(child: GameWidget(game: _game)),

          // Left side citizen panel
          const Positioned(top: 0, bottom: 0, left: 0, child: CitizenPanel()),

          // Top left controls
          Positioned(
            top: 20,
            left: 320, // Moved to the right of the citizen panel
            child: IconButton(
              icon: const Icon(
                Icons.power_settings_new,
                color: Colors.greenAccent,
              ),
              tooltip: 'Terminate Session',
              onPressed: () {
                // Return to the intro screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const IntroScreen()),
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
                  (!previous.isNewsReportPending &&
                      current.isNewsReportPending) ||
                  (!previous.isReportPending && current.isReportPending),
              listener: (context, state) {
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
                  previous.remainingTimeInDayInt !=
                      current.remainingTimeInDayInt ||
                  (previous.terroristThreat * 10).toInt() !=
                      (current.terroristThreat * 10).toInt(),
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(220),
                    border: Border.all(color: Colors.greenAccent, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'DAY: ${state.currentDay}',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'TIME: ${(Consts.dayDuration - state.remainingTimeInDayInt).toInt()} / ${Consts.dayDuration.toInt()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'THREAT LEVEL: ${state.terroristThreat.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: state.terroristThreat > 80
                              ? Colors.redAccent
                              : Colors.greenAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
