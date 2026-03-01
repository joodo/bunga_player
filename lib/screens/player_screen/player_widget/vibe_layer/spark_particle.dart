import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

abstract class SparkParticle {
  final ui.Image image;
  double life = 1.0;

  SparkParticle({required this.image});

  bool get isAlive => life > 0;

  void update(double delta);

  void draw(ui.Canvas canvas, Paint paint);
}

class GravityPartial extends SparkParticle {
  static const gravity = 0.6;
  static final _random = Random();

  final double scale;

  double x, y;
  final double vx;
  double vy; // Velocity

  double opacity = 1.0;
  final double decay;

  double rotation;
  final double rotationSpeed;

  GravityPartial({required super.image, required Offset start})
    : scale = _random.nextDouble() * (1 - 25 / 45) + 25 / 45,
      x = start.dx,
      y = start.dy,
      vx = (_random.nextDouble() - 0.5) * 6,
      vy = _random.nextDouble() * -10 - 5,
      decay = 0.008 / (_random.nextDouble() * (0.6 - 0.4) + 0.4),

      rotation = _random.nextDouble() * pi * 2,
      rotationSpeed = (_random.nextDouble() - 0.5) * 0.1;

  @override
  void update(double delta) {
    life -= decay * delta;
    opacity = life.clamp(0.0, 1.0);

    vy += gravity * delta;

    x += vx * delta;
    y += vy * delta;

    rotation += rotationSpeed * delta;
  }

  @override
  void draw(ui.Canvas canvas, Paint paint) {
    paint.color = Colors.white.withAlpha((opacity * 255).toInt());

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rotation);
    final scaleSize = scale * image.width;
    final offset = -scaleSize / 2;

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(offset, offset, scaleSize, scaleSize),
      paint,
    );

    canvas.restore();
  }
}

class PokePartial extends SparkParticle {
  static const vy = -5.0, decay = 0.03;

  late final double x;
  double y;

  double opacity = 1.0;

  PokePartial({required super.image, required Offset start}) : y = start.dy {
    x = start.dx - image.width / 2;
  }

  @override
  void update(double delta) {
    life -= decay * delta;
    opacity = life.clamp(0.0, 1.0);

    y += vy * delta;
  }

  @override
  void draw(ui.Canvas canvas, Paint paint) {
    paint.color = Colors.white.withAlpha((opacity * 255).toInt());

    canvas.save();
    canvas.translate(x, y);
    canvas.drawImage(image, Offset.zero, paint);
    canvas.restore();
  }
}

class RipplePartial extends SparkParticle {
  static final _random = Random();
  static const rippleSpeed = 0.02;

  double scale;

  final double x, y;

  double opacity = 1.0;
  final double decay;

  double rotation;

  RipplePartial({required super.image, required Offset start})
    : x = start.dx,
      y = start.dy,
      scale = _random.nextDouble() * (1 - 25 / 45) + 25 / 45,
      decay = 0.03 / (_random.nextDouble() * (0.6 - 0.4) + 0.4),
      rotation = _random.nextDouble() * pi * 2;

  @override
  void update(double delta) {
    life -= decay * delta;
    opacity = life.clamp(0.0, 1.0);

    scale += rippleSpeed * delta;
  }

  @override
  void draw(ui.Canvas canvas, Paint paint) {
    paint.color = Colors.white.withAlpha((opacity * 255).toInt());

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rotation);
    final scaleSize = scale * image.width;
    final offset = -scaleSize / 2;

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(offset, offset, scaleSize, scaleSize),
      paint,
    );

    canvas.restore();
  }
}
