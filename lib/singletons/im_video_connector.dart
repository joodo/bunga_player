import 'package:bunga_player/common/video_open.dart';
import 'package:bunga_player/singletons/im_controller.dart';
import 'package:bunga_player/singletons/logger.dart';
import 'package:bunga_player/singletons/snack_bar.dart';
import 'package:bunga_player/singletons/ui_notifiers.dart';
import 'package:bunga_player/singletons/video_controller.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class IMVideoConnector {
  // Singleton
  static final _instance = IMVideoConnector._internal();
  factory IMVideoConnector() => _instance;

  IMVideoConnector._internal() {
    IMController().channelUpdateEventNotifier.addListener(_onRoomDataChanged);
  }

  Future<void> _onRoomDataChanged() async {
    final event = IMController().channelUpdateEventNotifier.value!;
    logger.i('remote change room data: ${event.channel?.extraData.toString()}');

    final user = event.user;
    if (user == null || user == IMController().currentUserNotifier.value) {
      return;
    }
    showSnackBar('${user.name} 更换了影片');

    final extraData = event.channel!.extraData;

    if (extraData['video_type'] == 'bilibili') {
      followRemoteBiliVideoHash(extraData['hash'] as String);
    }
  }

  Future<void> followRemoteBiliVideoHash(String videoHash) async {
    UINotifiers().isBusy.value = true;
    try {
      await for (String hint in loadBiliVideoByHash(videoHash)) {
        UINotifiers().hintText.value = hint;
      }
    } catch (e) {
      logger.e(e);
    } finally {
      UINotifiers().hintText.value = null;
      UINotifiers().isBusy.value = false;
    }
  }

  bool get isVideoSameWithRoom =>
      IMController()
          .channelUpdateEventNotifier
          .value
          ?.channel
          ?.extraData['hash'] ==
      VideoController().videoHashNotifier.value;

  // About play status
  Future<void> sendPlayerStatus({String? quoteMessageId}) async {
    // Not playing the same video, ignore
    if (!isVideoSameWithRoom) return;

    final isPlay = VideoController().isPlaying.value;
    final position = VideoController().position.value;

    final messageText =
        '${isPlay ? "play" : "pause"} at ${position.inMilliseconds}';
    await IMController().sendMessage(
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
    // If I'm the only one watcher, no need to ask position
    if (IMController().channelWatchers.watchers!.length < 2) return;

    _askID = await IMController().sendMessage(Message(text: 'where'));

    Future.delayed(const Duration(seconds: 6), () {
      if (_askID != null) {
        logger.w('Asked position but no one answered');
        _askID = null;
      }
    });
  }

  void applyStatus(Event event) async {
    // Not playing the same video, ignore
    if (!isVideoSameWithRoom) return;

    final re = event.message!.text!.split(' ');

    bool canShowSnackBar = true;
    // If apply status is because asking where, then don't show snack bar
    if (_askID != null) canShowSnackBar = false;

    final isPlaying = VideoController().isPlaying.value;
    if (re.first == 'pause' && isPlaying) {
      VideoController().isPlaying.value = false;
      if (canShowSnackBar) {
        showSnackBar('${event.user!.name} 暂停了视频');
        canShowSnackBar = false;
      }
    }
    if (re.first == 'play' && !isPlaying) {
      VideoController().isPlaying.value = true;
      if (canShowSnackBar) {
        showSnackBar('${event.user!.name} 播放了视频');
        canShowSnackBar = false;
      }
    }

    final position = VideoController().position.value;
    final remotePosition = Duration(milliseconds: int.parse(re.last));
    if ((position - remotePosition).inMilliseconds.abs() > 1000) {
      VideoController().seekTo(remotePosition);
      if (canShowSnackBar) {
        showSnackBar('${event.user!.name} 调整了进度');
        canShowSnackBar = false;
      }
    }
  }

  Future<void> answerPlayStatus(Event event) async {
    if (_askID == null) {
      await sendPlayerStatus(quoteMessageId: event.message!.id);
    }
  }

  Future<void> processPlayStatus(Event event) async {
    final quoteID = event.message!.quotedMessageId;

    if (quoteID != null) {
      // Not answering me
      if (quoteID != _askID) return;

      applyStatus(event);
      _askID = null;
    } else {
      applyStatus(event);
    }
  }
}
