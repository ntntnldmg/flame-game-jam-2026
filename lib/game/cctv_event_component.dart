import 'dart:math';

import 'package:flame/components.dart';

import '../consts.dart';
import 'game_cubit.dart';

/// Periodically triggers the CCTV surveillance mini-game.
///
/// Fires every 30–45 seconds (randomised). Pauses while any overlay is active
/// so the timer never fires mid-report or mid-event.
class CCTVEventComponent extends Component {
  static final Random _random = Random();

  final GameCubit _gameCubit;
  double _accumulator = 0;
  late double _nextTrigger;
  bool _wasGameOver = false;

  CCTVEventComponent(this._gameCubit) {
    _nextTrigger = _randomInterval();
  }

  @override
  void update(double dt) {
    if (_gameCubit.isClosed) return;
    final s = _gameCubit.state;
    if (!s.hasStartedGame) return;
    if (s.isGameOver) {
      _wasGameOver = true;
      return;
    }
    if (_wasGameOver) {
      _wasGameOver = false;
      _accumulator = 0;
      _nextTrigger = _randomInterval();
    }
    if (s.isNewsReportPending || s.isReportPending || s.isCctvEventPending) {
      return;
    }
    _accumulator += dt;
    if (_accumulator >= _nextTrigger) {
      _accumulator = 0;
      _nextTrigger = _randomInterval();
      _gameCubit.triggerCctvEvent();
    }
  }

  double _randomInterval() =>
      Consts.cctvMinIntervalSeconds +
      _random.nextDouble() *
          (Consts.cctvMaxIntervalSeconds - Consts.cctvMinIntervalSeconds);
}
