import 'dart:math';

import 'package:async/async.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/chat/providers.dart';
import 'package:bunga_player/popmoji/models/data.dart';
import 'package:bunga_player/popmoji/models/message_data.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:fireworks/fireworks.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class PopmojiPlayer extends StatelessWidget {
  const PopmojiPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(builder: (context) => const _FireworkOverlay()),
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
    rocketSpawnTimeout: Duration.zero,
    autoLaunchDuration: Duration.zero,
  )..start();

  late final _fireworkTimer = RestartableTimer(
    const Duration(seconds: 3),
    () => _fireworkController.autoLaunchDuration = Duration.zero,
  );

  @override
  void initState() {
    super.initState();
    context.read<ChatChannelLastMessage>().addListener(startFireworks);
  }

  @override
  void dispose() {
    context.read<ChatChannelLastMessage>().removeListener(startFireworks);
    _fireworkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Fireworks(controller: _fireworkController);
  }

  void startFireworks() {
    final message = context.read<ChatChannelLastMessage>().value;
    if (message == null || !message.data.isPopmojiData) return;

    final popmojiData = message.data.toPopmojiData();
    if (popmojiData.code != '1f386') return;

    final isCurrentUser =
        message.sender.id == context.read<ChatUser>().value!.id;
    if (!isCurrentUser) getIt<Toast>().show('${message.sender.name} 在放大呲花');

    _fireworkController.autoLaunchDuration = const Duration(milliseconds: 100);
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

  @override
  void initState() {
    super.initState();
    context.read<ChatChannelLastMessage>().addListener(showPopmoji);
  }

  @override
  void dispose() {
    context.read<ChatChannelLastMessage>().removeListener(showPopmoji);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxEmojis = constraints.maxWidth ~/ _EmojiAnimation.maxSize;
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _popmojis
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
                .toList(),
          ),
        );
      },
    );
  }

  void showPopmoji() {
    final message = context.read<ChatChannelLastMessage>().value;
    if (message == null || !message.data.isPopmojiData) return;

    final popmojiData = message.data.toPopmojiData();
    if (popmojiData.code == '1f386') return;

    setState(() {
      _popmojis = [
        ..._popmojis,
        (
          id: _popmojiId++,
          sender: message.sender,
          code: message.data.toPopmojiData().code,
        ),
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
        tween: Tween<double>(begin: 0, end: maxSize)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(maxSize),
        weight: 3,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: maxSize, end: 0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 1,
      ),
    ]).animate(_animationController);
    _emojiSizeAnime = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0, end: maxEmojiSize)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 4,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: maxEmojiSize, end: 0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 1,
      ),
    ]).animate(_animationController);
    _textOpacityAnime = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(0),
        weight: 0.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0),
        weight: 0.5,
      ),
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
      builder: (context, child) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedOverflowBox(
            size: Size(_sizeAnime.value, 30),
            alignment: Alignment.topLeft,
            child: Opacity(
              opacity: _textOpacityAnime.value,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: _EmojiAnimation.maxSize,
                ),
                decoration: BoxDecoration(
                  color: widget.info.sender.getColor(0.3).withAlpha(220),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${widget.info.sender.name}:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ),
          SizedBox.square(
            dimension: _sizeAnime.value,
            child: Center(
              child: SizedBox(
                width: _emojiSizeAnime.value,
                child: child,
              ),
            ),
          ),
        ],
      ),
      child: Lottie.asset(
        EmojiData.lottiePath(EmojiData.emojiString(widget.info.code)),
        repeat: false,
        onLoaded: (composition) {
          _animationController.duration = composition.duration * 1.25;
          _animationController.forward();
        },
      ),
    );
  }
}
