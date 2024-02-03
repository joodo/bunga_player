import 'dart:async';

import 'package:bunga_player/providers/business/business_indicator.dart';
import 'package:bunga_player/screens/wrappers/toast.dart';
import 'package:bunga_player/services/bilibili.dart';
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/providers/states/current_channel.dart';
import 'package:bunga_player/providers/states/current_user.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/providers/business/video_player.dart';
import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class RemotePlaying {
  RemotePlaying(this._context) {
    final currentChannel = _context.read<CurrentChannel>();
    currentChannel.addListener(_onChannelChanged);
    currentChannel.channelDataNotifier.addListener(
      () {
        // Try to follow if it's bili video
        final channelData = currentChannel.channelDataNotifier.value;
        if (!isVideoSameWithRoom &&
            _context.read<VideoPlayer>().videoHashNotifier.value != null &&
            channelData?.videoType == VideoType.bilibili) {
          followRemoteBiliVideoHash(channelData!.videoHash);
        }
      },
    );
  }

  final BuildContext _context;

  Future _onChannelChanged() async {
    // Listen to new chat message
    final messageStream = _context.read<CurrentChannel>().messageStream;

    await _messageSubscription?.cancel();
    _messageSubscription = messageStream.listen((message) {
      if (message?.user?.id == _context.read<CurrentUser>().id) return;

      final prefix = message?.text?.split(' ').first;
      switch (prefix) {
        case 'pause':
        case 'play':
          _processPlayStatus(message!);
          break;

        case 'where':
          _answerPlayStatus(message!);
          break;

        default:
          return;
      }
    });
  }

  // Chat
  StreamSubscription? _messageSubscription;

  Future<void> followRemoteBiliVideoHash(String videoHash) async {
    final bi = _context.read<BusinessIndicator>();
    final showToast = _context.showToast;
    final videoPlayer = _context.read<VideoPlayer>();

    final biliEntry = BiliEntry.fromHash(videoHash);
    await bi.run(
      missions: [
        Mission(name: '正在鬼鬼祟祟……', tasks: [
          () async {
            videoPlayer.stop();

            await getService<Bilibili>().fetch(biliEntry);
            if (biliEntry is BiliVideo && !biliEntry.isHD) {
              showToast('无法获取高清视频');
            }
          },
        ]),
        Mission(name: '正在收拾客厅……', tasks: [
          () async {
            await videoPlayer.loadBiliVideo(biliEntry);
            await askPosition();
          },
        ]),
      ],
    );
  }

  bool get isVideoSameWithRoom =>
      _context.read<CurrentChannel>().channelDataNotifier.value?.videoHash ==
      _context.read<VideoPlayer>().videoHashNotifier.value;

  // About play status
  void sendPlayerStatus({String? quoteMessageId}) {
    final videoPlayer = _context.read<VideoPlayer>();

    // Not playing the same video, ignore
    if (!isVideoSameWithRoom) return;

    final isPlay = videoPlayer.isPlaying.value;
    final position = videoPlayer.position.value;

    final messageText =
        '${isPlay ? "play" : "pause"} at ${position.inMilliseconds}';
    _context.read<CurrentChannel>().send(
          Message(
            text: messageText,
            quotedMessageId: quoteMessageId,
          ),
        );
  }

  String? _askID;
  Future<void> askPosition() async {
    final message = Message(text: 'where');
    await _context.read<CurrentChannel>().send(message);
    _askID = message.id;

    Future.delayed(const Duration(seconds: 6), () {
      if (_askID != null) {
        logger.w('Asked position but no one answered');
        _askID = null;
      }
    });
  }

  // Prevent remote and local toggle video together
  bool _justToggledByRemote = false;
  bool get justToggledByRemote => _justToggledByRemote;
  late final _resetToggledByRemoteTimer = RestartableTimer(
    const Duration(seconds: 1),
    () => _justToggledByRemote = false,
  );
  void _markRemoteToggle() {
    _justToggledByRemote = true;
    _resetToggledByRemoteTimer.reset();
  }

  Future<void> _processPlayStatus(Message message) async {
    final quoteID = message.quotedMessageId;

    if (quoteID != null) {
      // Not answering me
      if (quoteID != _askID) return;
      _askID = null;
    }
    _applyStatus(message);
  }

  void _applyStatus(Message message) {
    // Not playing the same video, ignore
    if (!isVideoSameWithRoom) return;

    final videoPlayer = _context.read<VideoPlayer>();

    final re = message.text!.split(' ');

    bool canShowSnackBar = true;
    // If apply status is because asking where, then don't show snack bar
    if (_askID != null) canShowSnackBar = false;

    final isPlaying = videoPlayer.isPlaying.value;
    if (re.first == 'pause' && isPlaying) {
      videoPlayer.isPlaying.value = false;
      if (canShowSnackBar) {
        _context.showToast('${message.user!.name} 暂停了视频');
        canShowSnackBar = false;
        _markRemoteToggle();
      }
    }
    if (re.first == 'play' && !isPlaying) {
      videoPlayer.isPlaying.value = true;
      if (canShowSnackBar) {
        _context.showToast('${message.user!.name} 播放了视频');
        canShowSnackBar = false;
        _markRemoteToggle();
      }
    }

    final position = videoPlayer.position.value;
    final remotePosition = Duration(milliseconds: int.parse(re.last));
    if ((position - remotePosition).inMilliseconds.abs() > 1000) {
      videoPlayer.position.value = remotePosition;
      if (canShowSnackBar) {
        _context.showToast('${message.user!.name} 调整了进度');
        canShowSnackBar = false;
      }
    }
  }

  void _answerPlayStatus(Message message) {
    if (_askID == null) {
      sendPlayerStatus(quoteMessageId: message.id);
    }
  }
}
