import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:bunga_player/bunga_server/actions.dart';
import 'package:bunga_player/bunga_server/models/bunga_client_info.dart';
import 'package:bunga_player/client_info/providers.dart';
import 'package:bunga_player/screens/dialogs/settings/network.dart';
import 'package:bunga_player/screens/dialogs/settings/reaction.dart';
import 'package:bunga_player/screens/player_screen/player_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/utils/extensions/styled_widget.dart';

import 'dialogs/settings/settings.dart';
import 'dialogs/open_video/open_video.dart';
import 'widgets/loading_button_icon.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return [
      [
        const _NameButton(),
        const Spacer(),
        const _SettingButton(),
      ].toRow(),
      Consumer2<BungaClientInfo?, FetchingBungaClient>(
        builder: (context, infoNotifier, fetchingNotifier, child) =>
            infoNotifier == null && !fetchingNotifier.value
                ? _Arrow()
                : _waitingWidget(),
      ).flexible(),
      _OpenVideoButton(onFinished: _onFinished),
    ].toColumn().padding(all: 16.0).material();
  }

  Widget _waitingWidget() {
    final theme = Theme.of(context);
    return [
      Lottie.asset(
        'assets/images/watch_movie.zip',
      ),
      const Text('正在等待其他人放映……')
          .textStyle(theme.textTheme.headlineLarge!)
          .breath()
          .padding(top: 24.0, bottom: 48.0),
    ].toColumn().fittedBox().padding(vertical: 24.0).center();
  }

  void _onFinished(OpenVideoDialogResult? result) async {
    if (result == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlayerScreen(),
        settings: RouteSettings(arguments: result),
      ),
    );
  }
}

class _Arrow extends StatefulWidget {
  @override
  State<_Arrow> createState() => _ArrowState();
}

class _ArrowState extends State<_Arrow> with SingleTickerProviderStateMixin {
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

class _NameButton extends StatelessWidget {
  const _NameButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OpenContainer(
      closedBuilder: (context, openContainer) => TextButton(
        onPressed: openContainer,
        child: Selector<ClientNicknameNotifier, String>(
          selector: (context, notifier) => notifier.value,
          builder: (context, String nickname, child) =>
              Text(nickname.isNotEmpty ? '你好，$nickname' : '如何称呼你？')
                  .textStyle(theme.textTheme.titleMedium!),
        ),
      ),
      closedColor: theme.primaryColor,
      openBuilder: (dialogContext, closeContainer) => const Dialog.fullscreen(
        child: SettingsDialog(page: ReactionSettings),
      ),
      openColor: theme.primaryColor,
    );
  }
}

class _SettingButton extends StatelessWidget {
  const _SettingButton();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OpenContainer(
      closedBuilder: (context, openContainer) =>
          Consumer2<BungaClientInfo?, FetchingBungaClient>(
        builder: (context, clientInfo, fetchingNotifer, child) {
          final failed = !fetchingNotifer.value && clientInfo == null;
          return OutlinedButton.icon(
            icon: (fetchingNotifer.value
                    ? const LoadingButtonIcon(key: ValueKey('loading'))
                    : clientInfo == null
                        ? const Icon(key: ValueKey('error'), Icons.error)
                        : const Icon(key: ValueKey('settings'), Icons.settings))
                .animatedSwitcher(duration: const Duration(milliseconds: 200)),
            label: (fetchingNotifer.value
                    ? const Text('正在载入', key: ValueKey('loading'))
                    : Text(
                        clientInfo?.channel.name ?? '设置服务器',
                        key: const ValueKey('finished'),
                      ))
                .animatedSwitcher(duration: const Duration(milliseconds: 200))
                .animatedSize(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                ),
            onPressed: openContainer,
          ).colorScheme(seedColor: failed ? Colors.red : Colors.green);
        },
      ),
      closedColor: theme.primaryColor,
      openBuilder: (dialogContext, closeContainer) => const Dialog.fullscreen(
        child: SettingsDialog(page: NetworkSettings),
      ),
      openColor: theme.primaryColor,
    );
  }
}

class _OpenVideoButton extends StatelessWidget {
  final void Function(OpenVideoDialogResult?)? onFinished;
  const _OpenVideoButton({this.onFinished});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OpenContainer<OpenVideoDialogResult?>(
      closedBuilder: (context, openContainer) => FilledButton(
        onPressed: openContainer,
        child: const Text('我来放'),
      ).constrained(width: 100.0),
      closedColor: theme.primaryColor,
      openBuilder: (dialogContext, closeContainer) => const Dialog.fullscreen(
        child: OpenVideoDialog(),
      ),
      openColor: theme.primaryColor,
      onClosed: (data) {
        onFinished?.call(data);
      },
    );
  }
}
