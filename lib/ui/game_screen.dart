import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/big_brother_game.dart';
import 'intro_screen.dart';

/// The main screen where the game is rendered.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final BigBrotherGame _game;

  @override
  void initState() {
    super.initState();
    // Initialize the Flame game instance
    _game = BigBrotherGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The Flame game widget
          Positioned.fill(child: GameWidget(game: _game)),

          // Top left controls
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              tooltip: 'Back to Menu',
              onPressed: () {
                // Return to the intro screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const IntroScreen()),
                );
              },
            ),
          ),

          // Top right HUD for game state
          Positioned(
            top: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _game.gameState,
              builder: (context, child) {
                final state = _game.gameState;
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(180),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Day: ${state.currentDay}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Time: ${state.remainingTimeInDay}s',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Threat: ${state.terroristThreat.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: state.terroristThreat > 80
                              ? Colors.red
                              : Colors.redAccent,
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
