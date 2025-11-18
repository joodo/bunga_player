import 'dart:io';

import 'package:animations/animations.dart';
import 'package:bunga_player/ui/audio_player.dart';
import 'package:bunga_player/voice_call/client/client.agora.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/chat/models/message_data.dart';
import 'package:bunga_player/screens/dialogs/open_video/open_video.dart';
import 'package:bunga_player/screens/dialogs/open_video/direct_link.dart';
import 'package:bunga_player/screens/dialogs/video_conflict.dart';
import 'package:bunga_player/bunga_server/global_business.dart';
import 'package:bunga_player/bunga_server/models/bunga_server_info.dart';
import 'package:bunga_player/chat/global_business.dart';
import 'package:bunga_player/chat/models/message.dart';
import 'package:bunga_player/client_info/models/client_account.dart';
import 'package:bunga_player/play/models/video_record.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/screens/player_screen/player_screen.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/utils/extensions/file.dart';

import 'arrow.dart';
import 'open_video_button.dart';
import 'projection_card.dart';
import 'setting_button.dart';
import 'name_button.dart';
import 'wait_widget.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final _messageSubscription = context.read<Stream<Message>>().listen((
    message,
  ) {
    switch (message.data['code']) {
      case StartProjectionMessageData.messageCode:
        final data = StartProjectionMessageData.fromJson(message.data);
        _dealWithProjection(data);
      case WhatsOnMessageData.messageCode:
        _dealWithWhatsOn();
      case NowPlayingMessageData.messageCode:
        final data = NowPlayingMessageData.fromJson(message.data);
        _dealWithNotPlaying(data);
    }
  });

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
      [const NameButton(), const Spacer(), const SettingButton()].toRow(),
      _getContent().padding(vertical: 16.0).flexible(),
      OpenVideoButton(onFinished: _videoSelected),
    ].toColumn().padding(all: 16.0);
  }

  Widget _getContent() {
    if (_currentProjection != null) {
      return ProjectionCard(
        key: ValueKey(_currentProjection!.videoRecord.id),
        data: _currentProjection!,
        onTap: _joinChannel,
      );
    }

    return Consumer2<BungaServerInfo?, FetchingBungaClient>(
      builder: (context, infoNotifier, fetchingNotifier, child) =>
          infoNotifier == null && !fetchingNotifier.value
          ? Arrow()
          : WaitWidget(),
    );
  }

  void _dealWithProjection(StartProjectionMessageData data) {
    final autoJoin = context.read<AutoJoinChannelNotifier>().value;
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
    final isFirstShare = _currentProjection == null;

    _currentProjection = data;
    setState(() {});

    if (isCurrent) {
      context.read<BungaAudioPlayer>().playSfx('start_play');
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
    _dealWithProjection(
      StartProjectionMessageData(
        sharer: data.sharer,
        videoRecord: data.videoRecord,
      ),
    );
  }

  void _videoSelected(OpenVideoDialogResult? result) async {
    if (result == null) return;
    _pushRoute(result);
  }

  void _joinChannel() async {
    if (_currentProjection == null) return;
    final data = _currentProjection!;

    final record = data.videoRecord;
    if (record.source != 'local' || File(record.path).existsSync()) {
      _pushRoute(data.videoRecord);
    } else {
      // Remote local video not exist
      final path = await LocalVideoDialog.exec();
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

      _pushRoute(data.videoRecord.copyWith(path: path));
    }
  }

  void _pushRoute(dynamic argument) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlayerScreen(),
        settings: RouteSettings(arguments: argument),
      ),
    ).then((value) {
      if (!mounted) return;

      // Stop playing
      context.read<WindowTitleNotifier>().reset();
      getIt<PlayService>().stop();

      // Send bye message
      if (argument is OpenVideoDialogResult && !argument.onlyForMe ||
          argument is VideoRecord) {
        final myId = context.read<ClientAccount>().id;
        final byeData = ByeMessageData(userId: myId);
        Actions.invoke(context, SendMessageIntent(byeData));
      }

      // Stop talking
      context.read<AgoraClient?>()?.leaveChannel();
    });
  }
}
