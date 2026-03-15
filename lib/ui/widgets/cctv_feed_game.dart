import 'dart:math';

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import '../../audio/audio_settings.dart';
import '../../consts.dart';
import '../../game/game_cubit.dart';
import '../../models/resident.dart';
import '../../systems/resident_generator.dart';

class CctvFeedGame extends FlameGame {
  static final Random _random = Random();

  CctvFeedGame({required this.gameCubit, required this.baseScale});

  final GameCubit gameCubit;
  final double baseScale;

  final List<_Walker> _walkers = [];
  late _WalkerSprites _sprites;

  double _spawnCountdown = 0;
  bool _isDisposing = false;

  @override
  Color backgroundColor() => AppColors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _sprites = await _WalkerSprites.load(images);
    _scheduleNextSpawn();
  }

  @override
  void update(double dt) {
    if (_isDisposing || !isLoaded || !isMounted) return;
    super.update(dt);

    _spawnCountdown -= dt;
    while (_spawnCountdown <= 0) {
      _spawnWalker();
      _scheduleNextSpawn();
    }

    _walkers.removeWhere((walker) => walker.isRemoved);
  }

  void _scheduleNextSpawn() {
    final delayMs = 10 + _random.nextInt(9991); // 10..10000 ms
    _spawnCountdown = delayMs / 1000.0;
  }

  void _spawnWalker() {
    if (_isDisposing || !isLoaded || !isMounted) return;
    if (size.x <= 20 || size.y <= 20) return;

    final isUnregistered = _random.nextDouble() < 0.17;
    final resident = isUnregistered
        ? _generateUnregisteredResident()
        : _pickRegisteredResident();
    if (resident == null) return;

    final aspectRatio = _aspectForResident(resident);
    final maxScale = baseScale * (1 + Consts.cctvPerspectiveScaleFactor);
    final lanePadding =
        ((_Walker.spriteHeight * aspectRatio * maxScale) / 2) + 2;
    final x =
        lanePadding + _random.nextDouble() * max(1, size.x - (lanePadding * 2));
    final durationSeconds = 3 + _random.nextDouble() * 3; // 3..6

    final walker = _Walker(
      resident: resident,
      isUnregistered: isUnregistered,
      sprites: _sprites,
      laneX: x,
      travelDurationSeconds: durationSeconds,
      baseScale: baseScale,
    );

    _walkers.add(walker);
    add(walker);
  }

  double _aspectForResident(Resident resident) {
    return resident.sex.toLowerCase() == 'female'
        ? _sprites.femaleAspect
        : _sprites.maleAspect;
  }

  @override
  void onRemove() {
    _isDisposing = true;
    for (final walker in _walkers) {
      if (!walker.isRemoved) {
        walker.removeFromParent();
      }
    }
    _walkers.clear();
    super.onRemove();
  }

  Resident? _pickRegisteredResident() {
    final residents = gameCubit.state.todayResidents;
    if (residents.isEmpty) return null;
    return residents[_random.nextInt(residents.length)];
  }

  Resident _generateUnregisteredResident() {
    final existingIds = gameCubit.state.todayResidents.map((r) => r.id).toSet();

    var resident = ResidentGenerator.generateDailyResidents(1).first;
    while (existingIds.contains(resident.id)) {
      resident = ResidentGenerator.generateDailyResidents(1).first;
    }
    return resident;
  }

  void _registerResident(_Walker walker) {
    gameCubit.registerResidentFromCctv(walker.resident);
    walker.markRegistered();

    if (!AudioSettings.isEnabled) return;
    FlameAudio.play('register.ogg');
  }

  bool handleTap(Offset localPosition) {
    for (var i = _walkers.length - 1; i >= 0; i--) {
      final walker = _walkers[i];
      if (!walker.isUnregistered || walker.isRemoved) continue;
      if (walker.registrationHitRect.contains(localPosition)) {
        _registerResident(walker);
        return true;
      }
    }
    return false;
  }
}

class _WalkerSprites {
  const _WalkerSprites({
    required this.maleLeft,
    required this.maleRight,
    required this.maleLeftBlink,
    required this.maleRightBlink,
    required this.femaleLeft,
    required this.femaleRight,
    required this.femaleLeftBlink,
    required this.femaleRightBlink,
  });

  final Sprite maleLeft;
  final Sprite maleRight;
  final Sprite maleLeftBlink;
  final Sprite maleRightBlink;
  final Sprite femaleLeft;
  final Sprite femaleRight;
  final Sprite femaleLeftBlink;
  final Sprite femaleRightBlink;

  double get maleAspect => maleLeft.srcSize.x / maleLeft.srcSize.y;
  double get femaleAspect => femaleLeft.srcSize.x / femaleLeft.srcSize.y;

  static Future<_WalkerSprites> load(Images images) async {
    return _WalkerSprites(
      maleLeft: Sprite(await images.load('left_step.png')),
      maleRight: Sprite(await images.load('right_step.png')),
      maleLeftBlink: Sprite(await images.load('left_step_blink.png')),
      maleRightBlink: Sprite(await images.load('right_step_blink.png')),
      femaleLeft: Sprite(await images.load('left_step_female.png')),
      femaleRight: Sprite(await images.load('right_step_female.png')),
      femaleLeftBlink: Sprite(await images.load('left_step_female_blink.png')),
      femaleRightBlink: Sprite(
        await images.load('right_step_female_blink.png'),
      ),
    );
  }
}

class _Walker extends SpriteComponent with HasGameReference<CctvFeedGame> {
  static final Random _random = Random();
  static const double spriteHeight = 78;

  static final TextPaint _idPaint = TextPaint(
    style: const TextStyle(
      fontSize: 9,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
    ),
  );

  _Walker({
    required this.resident,
    required this.isUnregistered,
    required this.sprites,
    required this.laneX,
    required this.travelDurationSeconds,
    required this.baseScale,
  }) : super(anchor: Anchor.topCenter, priority: 10);

  final Resident resident;
  final _WalkerSprites sprites;
  final double laneX;
  final double travelDurationSeconds;
  final double baseScale;

  bool isUnregistered;

  double _stepAccumulator = 0;
  bool _isLeftStep = true;

  double _blinkAccumulator = 0;
  double _nextBlinkAt = 1.6 + _random.nextDouble() * 3.2;
  bool _isBlinking = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final aspectRatio = resident.sex.toLowerCase() == 'female'
        ? sprites.femaleAspect
        : sprites.maleAspect;
    size =
        Vector2(spriteHeight * aspectRatio, spriteHeight) *
        (resident.sex.toLowerCase() == 'female' ? 1.2 : 1.4);
    position = Vector2(laneX, -size.y);
    scale = Vector2.all(baseScale);
    sprite = _currentSprite;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final travelDistance = game.size.y + size.y + size.y;
    final velocity = travelDistance / travelDurationSeconds;
    position.y += velocity * dt;

    final progress = ((position.y + size.y) / (game.size.y + size.y)).clamp(
      0.0,
      1.0,
    );
    final scaleValue =
        baseScale * (1 + (progress * Consts.cctvPerspectiveScaleFactor));
    scale = Vector2.all(scaleValue);

    _stepAccumulator += dt;
    while (_stepAccumulator >= 0.2) {
      _stepAccumulator -= 0.2;
      _isLeftStep = !_isLeftStep;
    }

    _blinkAccumulator += dt;
    if (_isBlinking) {
      if (_blinkAccumulator >= 0.18) {
        _isBlinking = false;
        _blinkAccumulator = 0;
        _nextBlinkAt = 1.6 + _random.nextDouble() * 3.2;
      }
    } else if (_blinkAccumulator >= _nextBlinkAt) {
      _isBlinking = true;
      _blinkAccumulator = 0;
    }

    sprite = _currentSprite;

    if (hitRect.top > game.size.y) {
      removeFromParent();
    }
  }

  void markRegistered() {
    isUnregistered = false;
  }

  Rect get hitRect => Rect.fromLTWH(
    position.x - ((size.x * scale.x) * anchor.x),
    position.y - ((size.y * scale.y) * anchor.y),
    size.x * scale.x,
    size.y * scale.y,
  );

  Rect get registrationHitRect {
    final base = hitRect;
    if (!isUnregistered) return base;
    // Give a forgiving click target for fast-moving unregistered sprites.
    return base.inflate(6);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final headBoxHeight = size.y * 0.48;
    final headBoxWidth = headBoxHeight * 0.78;
    final headRect = Rect.fromLTWH(
      (size.x - headBoxWidth) / 2,
      size.y * 0.05,
      headBoxWidth,
      headBoxHeight,
    );
    final boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = isUnregistered ? AppColors.red : AppColors.textPrimary;

    canvas.drawRect(headRect, boxPaint);

    final label = isUnregistered ? 'unregistered' : resident.id;
    _idPaint.render(canvas, label, Vector2(0, -10));
  }

  Sprite get _currentSprite {
    final isFemale = resident.sex.toLowerCase() == 'female';

    if (isFemale) {
      if (_isLeftStep) {
        return _isBlinking ? sprites.femaleLeftBlink : sprites.femaleLeft;
      }
      return _isBlinking ? sprites.femaleRightBlink : sprites.femaleRight;
    }

    if (_isLeftStep) {
      return _isBlinking ? sprites.maleLeftBlink : sprites.maleLeft;
    }
    return _isBlinking ? sprites.maleRightBlink : sprites.maleRight;
  }
}
