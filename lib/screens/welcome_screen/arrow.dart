import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:styled_widget/styled_widget.dart';

class Arrow extends StatefulWidget {
  const Arrow({super.key});

  @override
  State<Arrow> createState() => _ArrowState();
}

class _ArrowState extends State<Arrow> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 3), () {
          _controller.forward(from: 0);
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipY: true,
      child: Lottie.asset(
        'assets/images/arrow.zip',
        height: 300.0,
        width: 300.0,
        fit: BoxFit.contain,
        controller: _controller,
      )
          .rotate(angle: math.pi * 1.5)
          .fittedBox()
          .alignment(Alignment.bottomRight)
          .padding(right: 64),
    );
  }
}
