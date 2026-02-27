import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:bunga_player/danmaku/business.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/chat/client/client.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/danmaku/models/models.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/ui/global_business.dart';

class SparkLayer extends StatefulWidget {
  const SparkLayer({super.key});

  @override
  State<SparkLayer> createState() => _SparkLayerState();
}

class _SparkLayerState extends State<SparkLayer>
    with SingleTickerProviderStateMixin {
  final _particles = <EmojiParticle>[];

  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  final _canvasKey = GlobalKey();

  late final StreamSubscription _subscription;

  final _syncMessageCooldown = <String, AutoResetNotifier>{};

  @override
  void initState() {
    super.initState();

    _subscription = context
        .read<ChatClient>()
        .messageStream
        .where((event) => event.data['code'] == SparkMessageData.messageCode)
        .listen((event) {
          final data = SparkMessageData.fromJson(event.data);
          _handleToast(event.sender, data.emoji);
          _addSpark(emoji: data.emoji, fraction: data.fraction);
        });

    _ticker = createTicker(_onTick);
    _ticker.start();

    _cacheEmoji();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _ticker.dispose();
    for (final notifier in _syncMessageCooldown.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: getIt<MediaPlayer>().videoSizeNotifier,
      builder: (context, videoSize, child) {
        if (videoSize == null) {
          return const SizedBox.shrink();
        }

        final canvas = CustomPaint(
          key: _canvasKey,
          painter: _SparkPainter(_particles),
          size: Size.infinite,
        );

        final widget = canvas
            .aspectRatio(aspectRatio: videoSize.aspectRatio)
            .center();

        return RepaintBoundary(child: widget);
      },
    );
  }

  void _onTick(Duration elapsed) {
    if (_particles.isEmpty) {
      _ticker.stop();
      _lastElapsed = Duration.zero;
      return;
    }

    final double delta =
        (elapsed.inMilliseconds - _lastElapsed.inMilliseconds) / 16.67;
    _lastElapsed = elapsed;
    setState(() {
      for (var particle in _particles) {
        particle.update(delta);
      }
      _particles.removeWhere((p) => !p.isAlive);
    });
  }

  void _handleToast(User user, String emoji) {
    if (user.isCurrent(context)) return;

    if (!_syncMessageCooldown.containsKey(user.id)) {
      _syncMessageCooldown[user.id] = AutoResetNotifier(
        const Duration(seconds: 2),
      );
    }

    final notifier = _syncMessageCooldown[user.id]!;
    if (!notifier.value) {
      context.read<PlaySyncMessageManager>().show('${user.name} 感到 $emoji');
    }
    notifier.mark();
  }

  void _addSpark({
    required String emoji,
    required FractionalOffset fraction,
  }) async {
    final canvasBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final canvasSize = canvasBox?.size;
    if (canvasSize == null) return;

    final sparkOffset = fraction.alongSize(canvasSize);

    _particles.add(
      EmojiParticle(image: await _getImage(emoji), start: sparkOffset),
    );

    if (!_ticker.isActive) {
      _lastElapsed = Duration.zero; // 重置参考时间
      _ticker.start();
    }
  }

  static final _emojiImageCache = {};
  Future<ui.Image> _getImage(String emoji) async {
    if (_emojiImageCache.containsKey(emoji)) {
      return _emojiImageCache[emoji];
    }

    final image = await EmojiData.createImage(emoji, 45.0);
    _emojiImageCache[emoji] = image;
    return image;
  }

  Future<void> _cacheEmoji() async {
    if (_emojiImageCache.isNotEmpty) return;

    for (final emoji in sparkOptions) {
      final image = await EmojiData.createImage(emoji, 45.0);
      _emojiImageCache[emoji] = image;
    }
  }
}

class EmojiParticle {
  static const gravity = 0.6;

  final ui.Image image;

  double life = 1.0;

  final double scale;

  double x, y;
  final double vx;
  double vy; // Velocity

  double opacity = 1.0;
  final double decay;

  double rotation;
  final double rotationSpeed;

  static final Random _random = Random();
  EmojiParticle({required this.image, required Offset start})
    : scale = _random.nextDouble() * (1 - 25 / 45) + 25 / 45,
      x = start.dx,
      y = start.dy,
      vx = (_random.nextDouble() - 0.5) * 6,
      vy = _random.nextDouble() * -10 - 5,
      decay = 0.008 / (_random.nextDouble() * (0.6 - 0.4) + 0.4),

      rotation = _random.nextDouble() * pi * 2,
      rotationSpeed = (_random.nextDouble() - 0.5) * 0.1;

  void update(double delta) {
    life -= decay * delta;
    opacity = life.clamp(0.0, 1.0);

    vy += gravity * delta;

    x += vx * delta;
    y += vy * delta;

    rotation += rotationSpeed * delta;
  }

  bool get isAlive => life > 0;
}

class _SparkPainter extends CustomPainter {
  final List<EmojiParticle> particles;

  _SparkPainter(this.particles);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint paint = Paint();

    for (final p in particles) {
      paint.color = Colors.white.withAlpha((p.opacity * 255).toInt());

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);
      final scaleSize = p.scale * p.image.width;
      final offset = -scaleSize / 2;

      canvas.drawImageRect(
        p.image,
        Rect.fromLTWH(
          0,
          0,
          p.image.width.toDouble(),
          p.image.height.toDouble(),
        ),
        Rect.fromLTWH(offset, offset, scaleSize, scaleSize),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
