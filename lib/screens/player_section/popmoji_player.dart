import 'package:bunga_player/services/chat.dart';
import 'package:fireworks/fireworks.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PopmojiPlayer extends StatefulWidget {
  const PopmojiPlayer({super.key});

  @override
  State<PopmojiPlayer> createState() => _PopmojiPlayerState();
}

class _PopmojiPlayerState extends State<PopmojiPlayer>
    with TickerProviderStateMixin {
  late final _animationController = AnimationController(vsync: this);

  // popmojis
  static const maxSize = 200.0;
  late final _sizeAnime = TweenSequence<double>([
    TweenSequenceItem<double>(
      tween: Tween<double>(begin: 0, end: maxSize)
          .chain(CurveTween(curve: Curves.elasticOut)),
      weight: 4,
    ),
    TweenSequenceItem<double>(
      tween: Tween<double>(begin: maxSize, end: 0)
          .chain(CurveTween(curve: Curves.easeInCubic)),
      weight: 1,
    ),
  ]).animate(_animationController);
  final _emojiCodeNotifier = ValueNotifier<String?>(null);

  // fireworks
  static const skyDarkness = 0.5;
  late final _fireworkController = FireworkController(
    vsync: this,
    withStars: false,
    withSky: false,
    rocketSpawnTimeout: Duration.zero,
    autoLaunchDuration: Duration.zero,
  );
  late final _skyAnime = TweenSequence<double>(
    [
      TweenSequenceItem(
        weight: 1.0,
        tween: Tween<double>(begin: 0, end: skyDarkness)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
      ),
      TweenSequenceItem(
        weight: 8.0,
        tween: ConstantTween(skyDarkness),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: Tween<double>(begin: skyDarkness, end: 0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
      ),
    ],
  ).animate(_animationController);

  @override
  void initState() {
    super.initState();
    _fireworkController.start();
    Chat()
        .messageStream
        .where((message) => message?.text?.split(' ')[0] == 'popmoji')
        .map<String?>((message) => message?.text?.split(' ')[1])
        .listen((code) => _emojiCodeNotifier.value = code);
  }

  @override
  dispose() {
    _animationController.dispose();
    _fireworkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: _emojiCodeNotifier,
      builder: (context, value, child) {
        final code = _emojiCodeNotifier.value;

        switch (code) {
          case null:
            return const SizedBox.shrink();

          // Fireworks
          case '1f386':
            _fireworkController.autoLaunchDuration =
                const Duration(milliseconds: 100);
            Future.delayed(const Duration(seconds: 3), () {
              _fireworkController.autoLaunchDuration = Duration.zero;
            });

            _animationController.duration = const Duration(seconds: 6);
            _animationController.reset();
            _animationController.forward();

            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => ColoredBox(
                color: Colors.black.withOpacity(_skyAnime.value),
                child: child,
              ),
              child: Fireworks(controller: _fireworkController),
            );

          default:
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) => Center(
                child: SizedBox(
                  width: _sizeAnime.value,
                  child: child,
                ),
              ),
              child: Lottie.asset(
                'assets/images/emojis/u$code.json',
                repeat: false,
                onLoaded: (composition) {
                  _animationController.duration = composition.duration * 1.25;
                  _animationController.reset();
                  _animationController
                      .forward()
                      .then((_) => _emojiCodeNotifier.value = null);
                },
              ),
            );
        }
      },
    );
  }
}
