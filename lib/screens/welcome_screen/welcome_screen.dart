import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/play/models/video_record.dart';
import 'package:bunga_player/ui/audio_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/chat/models/message_data.dart';
import 'package:bunga_player/screens/dialogs/open_video/open_video.dart';
import 'package:bunga_player/bunga_server/global_business.dart';
import 'package:bunga_player/bunga_server/models/bunga_server_info.dart';
import 'package:bunga_player/chat/models/message.dart';
import 'package:bunga_player/screens/player_screen/player_screen.dart';
import 'package:bunga_player/ui/global_business.dart';

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
        _dealWithProjection(message.sender, data);
      case NowPlayingMessageData.messageCode:
        final data = NowPlayingMessageData.fromJson(message.data);
        _dealWithNowPlaying(data.sharer, data.record);
      case ResetMessageData.messageCode:
        _cleanProjection();
    }
  });

  StartProjectionMessageData? _currentProjection;
  User? _currentSharer;

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
        sharer: _currentSharer!,
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

  void _dealWithProjection(User sharer, StartProjectionMessageData data) {
    final autoJoin = context.read<AutoJoinChannelNotifier>().value;
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
    final isFirstShare = _currentProjection == null;

    _currentProjection = data;
    _currentSharer = sharer;
    setState(() {});

    if (isCurrentRoute) {
      context.read<BungaAudioPlayer>().playSfx('start_play');
    }

    if (autoJoin && isCurrentRoute && isFirstShare) _joinChannel();
  }

  void _dealWithNowPlaying(User sharer, VideoRecord data) {
    //if (_currentProjection != null) return; // TODO: why?
    _dealWithProjection(sharer, StartProjectionMessageData(videoRecord: data));
  }

  void _videoSelected(OpenVideoDialogResult? result) async {
    if (result == null) return;
    _pushRoute(result);
  }

  void _joinChannel() async {
    if (_currentProjection == null) return;
    _pushRoute(null);
  }

  void _pushRoute(dynamic argument) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlayerScreen(),
        settings: RouteSettings(arguments: argument),
      ),
    );
  }

  void _cleanProjection() {
    setState(() {
      _currentProjection = null;
    });
  }
}
