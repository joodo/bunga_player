import 'dart:math' as math;
import 'dart:typed_data';

import 'package:animations/animations.dart';
import 'package:bunga_player/bunga_server/actions.dart';
import 'package:bunga_player/bunga_server/models/bunga_client_info.dart';
import 'package:bunga_player/chat/models/message.dart';
import 'package:bunga_player/client_info/providers.dart';
import 'package:bunga_player/screens/dialogs/settings/network.dart';
import 'package:bunga_player/screens/dialogs/settings/reaction.dart';
import 'package:bunga_player/screens/player_screen/player_screen.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/utils/extensions/http_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/utils/extensions/styled_widget.dart';

import '../chat/models/message_data.dart';
import 'dialogs/settings/settings.dart';
import 'dialogs/open_video/open_video.dart';
import 'widgets/loading_button_icon.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final _messageSubscription = context
      .read<Stream<Message>>()
      .where(
        (message) =>
            message.data['type'] == StartProjectionMessageData.messageType,
      )
      .map((message) => StartProjectionMessageData.fromJson(message.data))
      .listen(_dealWithProjection);

  StartProjectionMessageData? _currentProjection;

  @override
  void initState() {
    super.initState();
    _messageSubscription;
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return [
      [
        const _NameButton(),
        const Spacer(),
        const _SettingButton(),
      ].toRow(),
      _getContent().flexible(),
      _OpenVideoButton(onFinished: _onFinished),
    ].toColumn().padding(all: 16.0).material();
  }

  Widget _getContent() {
    if (_currentProjection != null) {
      return _ProjectionCard(
        _currentProjection!,
        key: ValueKey(_currentProjection!.videoRecord.id),
      );
    }

    return Consumer2<BungaClientInfo?, FetchingBungaClient>(
      builder: (context, infoNotifier, fetchingNotifier, child) =>
          infoNotifier == null && !fetchingNotifier.value
              ? _Arrow()
              : _WaitWidget(),
    ).flexible();
  }

  void _dealWithProjection(StartProjectionMessageData data) {
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
    setState(() {
      _currentProjection = data;
    });
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

class _WaitWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return [
      Lottie.asset(
        'assets/images/watch_movie.zip',
      ),
      const Text('正在等待其他人放映……')
          .textStyle(Theme.of(context).textTheme.headlineLarge!)
          .breath()
          .padding(top: 24.0, bottom: 48.0),
    ].toColumn().fittedBox().padding(vertical: 24.0).center();
  }
}

class _ProjectionCard extends StatefulWidget {
  final StartProjectionMessageData data;

  const _ProjectionCard(this.data, {super.key});

  @override
  State<_ProjectionCard> createState() => _ProjectionCardState();
}

class _ProjectionCardState extends State<_ProjectionCard> {
  Uint8List? _imageData;

  @override
  void initState() {
    super.initState();
    _getNetworkImageData(widget.data.videoRecord.thumbUrl ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final videoImage = _imageData != null
        ? Ink.image(
            image: MemoryImage(_imageData!),
            fit: BoxFit.cover,
            width: 300,
            height: 200,
          )
        : const SizedBox(
            width: 300,
            height: 200,
            child: Center(
              child: Icon(Icons.movie_creation_outlined, size: 80),
            ),
          );

    final textTheme = Theme.of(context).textTheme;
    final content = InkWell(
      onTap: _joinChannel,
      child: [
        const Text('正在播放')
            .textStyle(textTheme.titleLarge!)
            .padding(horizontal: 16.0, vertical: 16.0),
        videoImage,
        Text(
          widget.data.videoRecord.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ).textStyle(textTheme.bodyLarge!).padding(horizontal: 16.0, top: 8.0),
        Text('${widget.data.sharer.name} 分享')
            .textStyle(textTheme.bodySmall!)
            .padding(horizontal: 16.0, top: 4.0, bottom: 16.0),
      ]
          .toColumn(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
          )
          .constrained(width: 300),
    );

    final card = Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return content.card(
          color: colorScheme.primaryContainer,
          clipBehavior: Clip.hardEdge,
        );
      },
    );

    final themeData = Theme.of(context);
    try {
      return FutureBuilder(
        future: ColorScheme.fromImageProvider(
          provider: MemoryImage(_imageData!),
          brightness: Brightness.dark,
        ),
        initialData: themeData.colorScheme,
        builder: (context, snapshot) => Theme(
          data: themeData.copyWith(colorScheme: snapshot.data),
          child: card,
        ),
      ).center();
    } catch (e) {
      return card.center();
    }
  }

  void _getNetworkImageData(String uriString) async {
    try {
      final uri = Uri.parse(uriString);

      final response = await http.get(uri);
      if (!response.isSuccess) {
        throw Exception('image fetch failed: ${response.statusCode}');
      }
      _imageData = response.bodyBytes;

      if (mounted) setState(() {});
    } catch (e) {
      logger.w(e);
    }
  }

  void _joinChannel() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlayerScreen(),
        settings: RouteSettings(arguments: widget.data.videoRecord),
      ),
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
                  .textStyle(theme.textTheme.titleMedium!.copyWith(height: 0))
                  .padding(all: 8.0),
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
