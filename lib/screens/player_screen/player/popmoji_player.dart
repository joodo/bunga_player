import 'dart:async';
import 'dart:math';

import 'package:async/async.dart';
import 'package:bunga_player/chat/models/message.dart';
import 'package:bunga_player/chat/models/message_data.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/danmaku/models/data.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:fireworks/fireworks.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

class PopmojiPlayer extends StatelessWidget {
  const PopmojiPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => const _FireworkOverlay(),
          maintainState: true,
        ),
        OverlayEntry(builder: (context) => const _PopmojiOverlay()),
      ],
    );
  }
}

class _FireworkOverlay extends StatefulWidget {
  const _FireworkOverlay();
  @override
  State<_FireworkOverlay> createState() => _FireworkOverlayState();
}

class _FireworkOverlayState extends State<_FireworkOverlay>
    with TickerProviderStateMixin {
  late final _fireworkController = FireworkController(
    vsync: this,
    withStars: false,
    withSky: false,
    explosionParticleCount: kIsDesktop ? 80 : 20,
    rocketSpawnTimeout: Duration.zero,
    autoLaunchDuration: Duration.zero,
  )..start();

  late final _fireworkTimer = RestartableTimer(
    const Duration(seconds: 3),
    () => _fireworkController.autoLaunchDuration = Duration.zero,
  );

  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = context
        .read<Stream<Message>>()
        .where(
          (message) =>
              message.data['code'] == PopmojiMessageData.messageCode &&
              message.data['code'] == '🎆',
        )
        .map((message) {
          final data = PopmojiMessageData.fromJson(message.data);
          return data.sender;
        })
        .listen(_startFireworks);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _fireworkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Fireworks(controller: _fireworkController);
  }

  void _startFireworks(User sender) {
    getIt<Toast>().show('${sender.name} 在放大呲花');
    _fireworkController.autoLaunchDuration = Duration(
      milliseconds: kIsDesktop ? 100 : 400,
    );
    _fireworkTimer.reset();
  }
}

class _PopmojiOverlay extends StatefulWidget {
  const _PopmojiOverlay();

  @override
  State<_PopmojiOverlay> createState() => _PopmojiOverlayState();
}

typedef _PopmojiInfo = ({int id, String code, User sender});

class _PopmojiOverlayState extends State<_PopmojiOverlay> {
  int _popmojiId = 0;
  List<_PopmojiInfo> _popmojis = [];

  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = context
        .read<Stream<Message>>()
        .where(
          (message) =>
              message.data['code'] == PopmojiMessageData.messageCode &&
              message.data['code'] != '🎆',
        )
        .map((message) {
          final data = PopmojiMessageData.fromJson(message.data);
          return (data.sender, data.code);
        })
        .listen(_showPopmoji);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxEmojis = constraints.maxWidth ~/ _EmojiAnimation.maxSize;
        return _popmojis
            .sublist(0, min(maxEmojis, _popmojis.length))
            .map(
              (info) => _EmojiAnimation(
                key: ValueKey(info.id),
                info: info,
                onFinished: () => setState(() {
                  _popmojis.remove(info);
                }),
              ),
            )
            .toList()
            .toRow(mainAxisSize: MainAxisSize.min)
            .center();
      },
    );
  }

  void _showPopmoji((User, String) data) {
    setState(() {
      _popmojis = [
        ..._popmojis,
        (id: _popmojiId++, sender: data.$1, code: data.$2),
      ];
    });
  }
}

class _EmojiAnimation extends StatefulWidget {
  static const maxSize = 240.0;

  final _PopmojiInfo info;
  final VoidCallback? onFinished;

  const _EmojiAnimation({super.key, required this.info, this.onFinished});

  @override
  State<_EmojiAnimation> createState() => _EmojiAnimationState();
}

class _EmojiAnimationState extends State<_EmojiAnimation>
    with TickerProviderStateMixin {
  late final _animationController = AnimationController(vsync: this);

  late final Animation<double> _sizeAnime;
  late final Animation<double> _emojiSizeAnime;
  late final Animation<double> _textOpacityAnime;

  @override
  void initState() {
    super.initState();

    const maxSize = _EmojiAnimation.maxSize;
    const maxEmojiSize = maxSize / 1.2;

    _sizeAnime = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: maxSize,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 1,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(maxSize), weight: 3),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: maxSize,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 1,
      ),
    ]).animate(_animationController);
    _emojiSizeAnime = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0,
          end: maxEmojiSize,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 4,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: maxEmojiSize,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 1,
      ),
    ]).animate(_animationController);
    _textOpacityAnime = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 0.5),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 1,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 2),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 1,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0), weight: 0.5),
    ]).animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onFinished?.call();
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) =>
          [
            SizedOverflowBox(
              size: Size(_sizeAnime.value, 30),
              alignment: Alignment.topLeft,
              child: Text('${widget.info.sender.name}:')
                  .textStyle(Theme.of(context).textTheme.bodyLarge!)
                  .padding(all: 8.0)
                  .backgroundColor(
                    widget.info.sender.getColor(brightness: 0.3).withAlpha(200),
                  )
                  .borderRadius(all: 4.0)
                  .constrained(maxWidth: _EmojiAnimation.maxSize)
                  .opacity(_textOpacityAnime.value),
            ),
            child!
                .constrained(width: _emojiSizeAnime.value)
                .center()
                .constrained(height: _sizeAnime.value, width: _sizeAnime.value),
          ].toColumn(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
      child: Lottie.asset(
        EmojiData.lottiePath(widget.info.code),
        repeat: false,
        onLoaded: (composition) {
          _animationController.duration = composition.duration * 1.25;
          _animationController.forward();
        },
      ),
    );
  }
}
