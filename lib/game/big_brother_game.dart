import 'package:flame/game.dart';
import 'game_state.dart';

/// The main game class extending FlameGame.
/// Handles the game loop and component management.
class BigBrotherGame extends FlameGame {
  final GameState gameState = GameState();

  @override
  Future<void> onLoad() async {
    // Initialization logic goes here
    // e.g., loading assets, adding initial components
    await super.onLoad();
  }

  @override
  void update(double dt) {
    // Main game loop update
    super.update(dt);

    // Update game state
    gameState.updateTime(dt);
  }
}
