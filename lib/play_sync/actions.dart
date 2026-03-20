import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/chat/client/client.dart';
import 'package:bunga_player/chat/global_business.dart';
import 'package:bunga_player/chat/models/models.dart';
import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/play/models/video_record.dart';
import 'package:bunga_player/play/payload_parser.dart';
import 'package:bunga_player/play/service/service.dart';

import 'overlay_manager.dart';

class JoinInIntent extends Intent {
  final VideoRecord? myRecord;

  const JoinInIntent({this.myRecord});
}

class JoinInAction extends ContextAction<JoinInIntent> {
  @override
  void invoke(JoinInIntent intent, [BuildContext? context]) {
    final projection = intent.myRecord == null
        ? null
        : StartProjectionMessageData(videoRecord: intent.myRecord!);
    final data = JoinInMessageData(
      user: User.of(context!),
      myShare: projection,
    );
    context.sendMessage(data);
  }
}

class ShareVideoIntent extends Intent {
  final VideoRecord? record;
  final Uri? url;
  const ShareVideoIntent(this.record) : url = null;
  const ShareVideoIntent.url(this.url) : record = null;
}

class ShareVideoAction extends ContextAction<ShareVideoIntent> {
  ShareVideoAction();

  @override
  Future<void> invoke(ShareVideoIntent intent, [BuildContext? context]) async {
    final client = context!.read<ChatClient?>();
    final record =
        intent.record ?? await PlayPayloadParser(context).parseUrl(intent.url!);

    final data = StartProjectionMessageData(videoRecord: record);
    client!.sendMessage(data.toJson());
  }
}

class OpenVideoBeforeShareAction extends ContextAction<OpenVideoIntent> {
  final BuildContext parentContext;

  OpenVideoBeforeShareAction({required this.parentContext});

  @override
  Object? invoke(OpenVideoIntent intent, [BuildContext? context]) {
    final playService = MediaPlayer.i;
    final messageData = PauseMessageData(
      position: playService.positionNotifier.value,
    );
    context!.sendMessage(messageData);

    return Actions.invoke(parentContext, intent);
  }
}

class IndirectToggleAction extends ContextAction<IndirectToggleIntent> {
  final ValueListenable<bool> remoteJustToggled;
  final PlaybackOverlayManager playbackOverlay;

  IndirectToggleAction({
    required this.remoteJustToggled,
    required this.playbackOverlay,
  });

  @override
  void invoke(IndirectToggleIntent intent, [BuildContext? context]) {
    final player = MediaPlayer.i;
    final wantPlay = !player.playStatusNotifier.value.isPlaying;
    playbackOverlay.show(wantPlay ? .pendingPlaying : .pause);

    late final MessageData messageData;
    if (wantPlay) {
      messageData = PlayMessageData();
    } else {
      // pause control by myself
      player.pause();
      messageData = PauseMessageData(position: player.positionNotifier.value);
    }
    context!.sendMessage(messageData);
  }

  @override
  bool isEnabled(IndirectToggleIntent intent, [BuildContext? context]) {
    return !remoteJustToggled.value;
  }
}

class DirectSetPlaybackAction extends ContextAction<DirectSetPlaybackIntent> {
  final ValueListenable<bool> remoteJustToggled;
  final PlaybackOverlayManager playbackOverlay;

  DirectSetPlaybackAction({
    required this.remoteJustToggled,
    required this.playbackOverlay,
  });

  @override
  void invoke(DirectSetPlaybackIntent intent, [BuildContext? context]) {
    final player = MediaPlayer.i;
    final wantPlay = intent.isPlay;

    late final MessageData messageData;
    if (wantPlay) {
      messageData = PlayMessageData();
      // Show pending until channel status confirms real playback.
      playbackOverlay.show(.pendingPlaying);
    } else {
      // pause control by myself
      player.pause();
      messageData = PauseMessageData(position: player.positionNotifier.value);
    }
    context!.sendMessage(messageData);
  }

  @override
  bool isEnabled(DirectSetPlaybackIntent intent, [BuildContext? context]) {
    return !remoteJustToggled.value;
  }
}

class SyncSeekForwardAction extends ContextAction<SeekForwardIntent> {
  @override
  void invoke(SeekForwardIntent intent, [BuildContext? context]) {
    final player = MediaPlayer.i;
    player.seek(intent.position);

    final messageData = SeekMessageData(position: intent.position);
    context!.sendMessage(messageData);
  }
}

class SyncSeekStartAction extends ContextAction<SeekStartIntent> {
  final VoidCallback onSeekStart;

  SyncSeekStartAction({required this.onSeekStart});

  @override
  void invoke(SeekStartIntent intent, [BuildContext? context]) {
    onSeekStart();
  }
}

class SyncSeekEndAction extends ContextAction<SeekEndIntent> {
  final VoidCallback onSeekEnd;

  SyncSeekEndAction({required this.onSeekEnd});

  @override
  void invoke(SeekEndIntent intent, [BuildContext? context]) {
    final player = MediaPlayer.i;
    final messageData = SeekMessageData(
      position: player.positionNotifier.value,
    );
    context!.sendMessage(messageData);

    onSeekEnd();
  }
}
