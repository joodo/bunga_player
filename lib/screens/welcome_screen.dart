import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:animations/animations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/bunga_server/global_business.dart';
import 'package:bunga_player/bunga_server/models/bunga_client_info.dart';
import 'package:bunga_player/chat/actions.dart';
import 'package:bunga_player/chat/models/message.dart';
import 'package:bunga_player/client_info/providers.dart';
import 'package:bunga_player/screens/dialogs/open_video/direct_link.dart';
import 'package:bunga_player/screens/dialogs/settings/network.dart';
import 'package:bunga_player/screens/dialogs/settings/reaction.dart';
import 'package:bunga_player/screens/dialogs/video_conflict.dart';
import 'package:bunga_player/screens/player_screen/player_screen.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/utils/extensions/file.dart';
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
  late final _messageSubscription = context.read<Stream<Message>>().listen(
    (message) {
      switch (message.data['type']) {
        case StartProjectionMessageData.messageType:
          final data = StartProjectionMessageData.fromJson(message.data);
          _dealWithProjection(data);
        case WhatsOnMessageData.messageType:
          _dealWithWhatsOn();
        case NowPlayingMessageData.messageType:
          final data = NowPlayingMessageData.fromJson(message.data);
          _dealWithNotPlaying(data);
      }
    },
  );

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
      _getContent().padding(vertical: 16.0).flexible(),
      _OpenVideoButton(onFinished: _videoSelected),
    ].toColumn().padding(all: 16.0).material();
  }

  Widget _getContent() {
    if (_currentProjection != null) {
      return _ProjectionCard(
        key: ValueKey(_currentProjection!.videoRecord.id),
        data: _currentProjection!,
        onTap: _joinChannel,
      );
    }

    return Consumer2<BungaClientInfo?, FetchingBungaClient>(
      builder: (context, infoNotifier, fetchingNotifier, child) =>
          infoNotifier == null && !fetchingNotifier.value
              ? _Arrow()
              : _WaitWidget(),
    );
  }

  void _dealWithProjection(StartProjectionMessageData data) {
    final autoJoin = context.read<AutoJoinChannel>().value;
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
    final isFirstShare = _currentProjection == null;

    _currentProjection = data;
    setState(() {});

    if (isCurrent) {
      AudioPlayer().play(
        AssetSource('sounds/start_play.mp3'),
        mode: PlayerMode.lowLatency,
      );
    }

    if (autoJoin && isCurrent && isFirstShare) _joinChannel();
  }

  void _dealWithWhatsOn() {
    if (_currentProjection == null) return;

    final messageData = NowPlayingMessageData(
      videoRecord: _currentProjection!.videoRecord,
      sharer: _currentProjection!.sharer,
    );
    Actions.invoke(context, SendMessageIntent(messageData));
  }

  void _dealWithNotPlaying(NowPlayingMessageData data) {
    if (_currentProjection != null) return;
    _dealWithProjection(StartProjectionMessageData(
      sharer: data.sharer,
      videoRecord: data.videoRecord,
    ));
  }

  void _videoSelected(OpenVideoDialogResult? result) async {
    if (result == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlayerScreen(),
        settings: RouteSettings(arguments: result),
      ),
    );
  }

  void _joinChannel() async {
    if (_currentProjection == null) return;
    final data = _currentProjection!;

    final record = data.videoRecord;
    if (record.source != 'local' ||
        await File(record.path).exists() && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PlayerScreen(),
          settings: RouteSettings(
            arguments: data.videoRecord,
          ),
        ),
      );
    } else {
      final path = await LocalVideoEntryDialog.exec();
      if (path == null) return;

      final file = File(path);
      final crc = await file.crcString();

      if (!mounted) return;
      if (!record.id.endsWith(crc)) {
        final confirmOpen = await showModal<bool>(
          context: context,
          builder: (context) => const VideoConflictDialog(),
        );
        if (!mounted || confirmOpen != true) return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PlayerScreen(),
          settings: RouteSettings(
            arguments: data.videoRecord.copyWith(path: path),
          ),
        ),
      );
    }
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
  final VoidCallback? onTap;

  const _ProjectionCard({super.key, required this.data, this.onTap});

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
              child: Icon(Icons.smart_display, size: 180),
            ),
          );

    final textTheme = Theme.of(context).textTheme;
    final content = InkWell(
      onTap: widget.onTap,
      child: [
        videoImage,
        Text(
          widget.data.videoRecord.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ).textStyle(textTheme.bodyLarge!).padding(horizontal: 16.0, top: 8.0),
        Text('${widget.data.sharer.name} 正在分享')
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
      ).fittedBox().center();
    } catch (e) {
      return card.fittedBox().center();
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
