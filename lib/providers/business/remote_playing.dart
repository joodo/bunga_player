import 'dart:async';

import 'package:bunga_player/services/bilibili.dart';
import 'package:bunga_player/models/chat/channel_data.dart';
import 'package:bunga_player/providers/states/current_channel.dart';
import 'package:bunga_player/providers/states/current_user.dart';
import 'package:bunga_player/providers/ui/ui.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/providers/ui/toast.dart';
import 'package:bunga_player/providers/business/video_player.dart';
import 'package:bunga_player/services/services.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class RemotePlaying {
  RemotePlaying(Locator read)
      : _read = read,
        _currentUser = read<CurrentUser>(),
        _currentChannel = read<CurrentChannel>(),
        _videoPlayer = read<VideoPlayer>() {
    _currentChannel.addListener(_onChannelChanged);
    _currentChannel.channelDataNotifier.addListener(
      () {
        // Try to follow if it's bili video
        final channelData = _currentChannel.channelDataNotifier.value;
        if (!isVideoSameWithRoom &&
            channelData?.videoType == VideoType.bilibili) {
          followRemoteBiliVideoHash(channelData!.videoHash);
        }
      },
    );
  }

  final Locator _read;

  Future _onChannelChanged() async {
    // Listen to new chat message
    await _messageSubscription?.cancel();
    _messageSubscription = _currentChannel.messageStream.listen((message) {
      if (message?.user?.id == _currentUser.id) return;

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
  final CurrentUser _currentUser;
  final CurrentChannel _currentChannel;
  final VideoPlayer _videoPlayer;
  StreamSubscription? _messageSubscription;

  Future<void> followRemoteBiliVideoHash(String videoHash) async {
    final isBusy = _read<IsBusy>();
    final businessName = _read<BusinessName>();

    try {
      isBusy.value = true;
      await for (var hintText in loadBiliEntry(BiliEntry.fromHash(videoHash))) {
        businessName.value = hintText;
      }
      await askPosition();
    } catch (e) {
      logger.e(e);
    } finally {
      businessName.value = null;
      isBusy.value = false;
    }
  }

  Stream<String> loadBiliEntry(BiliEntry biliEntry) async* {
    _videoPlayer.stop();

    yield '正在鬼鬼祟祟……';
    await getService<Bilibili>().fetch(biliEntry);
    final showSnackBar = _read<Toast>().show;
    if (biliEntry is BiliVideo && !biliEntry.isHD) {
      showSnackBar('无法获取高清视频');
      logger.w('Bilibili: Cookie of serverless funtion outdated');
    }

    yield '正在收拾客厅……';
    await _videoPlayer.loadBiliVideo(biliEntry);
  }

  bool get isVideoSameWithRoom =>
      _currentChannel.channelDataNotifier.value?.videoHash ==
      _videoPlayer.videoHashNotifier.value;

  // About play status
  void sendPlayerStatus({String? quoteMessageId}) {
    // Not playing the same video, ignore
    if (!isVideoSameWithRoom) return;

    final isPlay = _videoPlayer.isPlaying.value;
    final position = _videoPlayer.position.value;

    final messageText =
        '${isPlay ? "play" : "pause"} at ${position.inMilliseconds}';
    _currentChannel.send(
      Message(
        text: messageText,
        quotedMessageId: quoteMessageId,
      ),
    );
  }

  String? _askID;
  Future<void> askPosition() async {
    // Not playing the same video, ignore
    if (!isVideoSameWithRoom) return;

    final message = Message(text: 'where');
    await _currentChannel.send(message);
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

    final re = message.text!.split(' ');

    bool canShowSnackBar = true;
    // If apply status is because asking where, then don't show snack bar
    if (_askID != null) canShowSnackBar = false;

    final isPlaying = _videoPlayer.isPlaying.value;
    final showSnackBar = _read<Toast>().show;
    if (re.first == 'pause' && isPlaying) {
      _videoPlayer.isPlaying.value = false;
      if (canShowSnackBar) {
        showSnackBar('${message.user!.name} 暂停了视频');
        canShowSnackBar = false;
        _markRemoteToggle();
      }
    }
    if (re.first == 'play' && !isPlaying) {
      _videoPlayer.isPlaying.value = true;
      if (canShowSnackBar) {
        showSnackBar('${message.user!.name} 播放了视频');
        canShowSnackBar = false;
        _markRemoteToggle();
      }
    }

    final position = _videoPlayer.position.value;
    final remotePosition = Duration(milliseconds: int.parse(re.last));
    if ((position - remotePosition).inMilliseconds.abs() > 1000) {
      _videoPlayer.position.value = remotePosition;
      if (canShowSnackBar) {
        showSnackBar('${message.user!.name} 调整了进度');
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
