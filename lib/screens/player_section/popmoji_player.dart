import 'dart:async';

import 'package:bunga_player/chat/providers.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:fireworks/fireworks.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class PopmojiPlayer extends StatefulWidget {
  const PopmojiPlayer({super.key});

  @override
  State<PopmojiPlayer> createState() => _PopmojiPlayerState();
}

class _PopmojiPlayerState extends State<PopmojiPlayer> {
  late final _channelMessage = context.read<ChatChannelLastMessage>();
  BuildContext? _dialogContext;

  @override
  void initState() {
    super.initState();
    _channelMessage.addListener(_progressMessage);
  }

  @override
  void dispose() {
    _channelMessage.removeListener(_progressMessage);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        builder: (context) {
          _dialogContext = context;
          return const SizedBox.shrink();
        },
      ),
      requestFocus: false,
    );
  }

  void _progressMessage() async {
    final message = context.read<ChatChannelLastMessage>().value;
    if (message == null) return;

    final splits = message.text.split(' ');

    if (splits.first == 'popmoji') {
      final isCurrentUser =
          message.sender.id == context.read<ChatUser>().value!.id;

      final code = splits[1];
      if (code == '1f386') {
        if (!isCurrentUser) getIt<Toast>().show('${message.sender.name} 在放大呲花');
        await _showFireworks();
      } else {
        if (!isCurrentUser) getIt<Toast>().show('${message.sender.name} 发来表情');
        await _showPopmoji(code);
      }

      logger.i('Popmoji: finish code $code');
    }
  }

  Future<void> _showFireworks() {
    return showDialog(
      context: _dialogContext!,
      useRootNavigator: false,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.transparent,
        child: _FireworkContent(),
      ),
    );
  }

  Future<void> _showPopmoji(String code) {
    return showDialog(
      context: _dialogContext!,
      useRootNavigator: false,
      barrierColor: Colors.transparent,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.transparent,
        child: _PopmojiContent(code: code),
      ),
    );
  }
}

class _FireworkContent extends StatefulWidget {
  @override
  State<_FireworkContent> createState() => _FireworkContentState();
}

class _FireworkContentState extends State<_FireworkContent>
    with TickerProviderStateMixin {
  late final _fireworkController = FireworkController(
    vsync: this,
    withStars: false,
    withSky: false,
    rocketSpawnTimeout: Duration.zero,
    autoLaunchDuration: const Duration(milliseconds: 100),
  )..start();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () {
        _fireworkController.autoLaunchDuration = Duration.zero;
      });

      final route = ModalRoute.of(context)!;
      final navigator = Navigator.of(context);
      Future.delayed(const Duration(seconds: 7), () {
        route.didPop(null);
        navigator.removeRoute(route);
      });
    });
  }

  @override
  void dispose() {
    _fireworkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Fireworks(controller: _fireworkController);
  }
}

class _PopmojiContent extends StatefulWidget {
  final String code;
  const _PopmojiContent({required this.code});

  @override
  State<_PopmojiContent> createState() => _PopmojiContentState();
}

class _PopmojiContentState extends State<_PopmojiContent>
    with TickerProviderStateMixin {
  late final _animationController = AnimationController(vsync: this);

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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context)!;
      final navigator = Navigator.of(context);
      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          route.didPop(null);
          navigator.removeRoute(route);
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
      builder: (context, child) => Center(
        child: SizedBox(
          width: _sizeAnime.value,
          child: child,
        ),
      ),
      child: Lottie.asset(
        'assets/images/emojis/u${widget.code}.json',
        repeat: false,
        onLoaded: (composition) {
          _animationController.duration = composition.duration * 1.25;
          _animationController.forward();
        },
      ),
    );
  }
}
