import 'package:bunga_player/common/bili_entry.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/snack_bar.dart';
import 'package:bunga_player/controllers/ui_notifiers.dart';
import 'package:bunga_player/services/video_player.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:window_manager/window_manager.dart';

class PlayerController {
  // Singleton
  static final _instance = PlayerController._internal();
  factory PlayerController() => _instance;

  PlayerController._internal() {
    Chat().channelExtraDataNotifier.addListener(_onRoomDataChanged);
    Chat().messageStream.where((message) {
      final prefix = message?.text?.split(' ').first;
      return prefix == 'pause' || prefix == 'play';
    }).listen((message) => _processPlayStatus(message!));
    Chat()
        .messageStream
        .where((message) => message?.text?.split(' ').first == 'where')
        .listen((message) => _answerPlayStatus(message!));
  }

  Future<void> _onRoomDataChanged() async {
    final extraData = Chat().channelExtraDataNotifier.value;

    if (!isVideoSameWithRoom && extraData['video_type'] == 'bilibili') {
      followRemoteBiliVideoHash(extraData['hash'] as String);
    }
  }

  Future<void> followRemoteBiliVideoHash(String videoHash) async {
    UINotifiers().isBusy.value = true;
    try {
      await loadBiliEntry(BiliEntry.fromHash(videoHash));
    } catch (e) {
      logger.e(e);
    } finally {
      UINotifiers().isBusy.value = false;
    }
  }

  Future<void> loadBiliEntry(BiliEntry biliEntry) async {
    try {
      VideoPlayer().stop();

      UINotifiers().hintText.value = '正在鬼鬼祟祟……';
      await biliEntry.fetch();
      if (!biliEntry.isHD) {
        showSnackBar('无法获取高清视频');
        logger.w('Bilibili: Cookie of serverless funtion outdated');
      }

      UINotifiers().hintText.value = '正在收拾客厅……';
      await VideoPlayer().loadBiliVideo(biliEntry);

      windowManager.setTitle(biliEntry.title);
    } finally {
      UINotifiers().hintText.value = null;
    }
  }

  bool get isVideoSameWithRoom =>
      Chat().channelExtraDataNotifier.value['hash'] ==
      VideoPlayer().videoHashNotifier.value;

  // About play status
  Future<void> sendPlayerStatus({String? quoteMessageId}) async {
    // Not playing the same video, ignore
    if (!isVideoSameWithRoom) return;

    // HACK: wait for https://github.com/alexmercerind/media_kit/issues/253
    await Future.delayed(const Duration(milliseconds: 100));

    final isPlay = VideoPlayer().isPlaying.value;
    final position = VideoPlayer().position.value;

    final messageText =
        '${isPlay ? "play" : "pause"} at ${position.inMilliseconds}';
    await Chat().sendMessage(
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

    _askID = await Chat().sendMessage(Message(text: 'where'));

    Future.delayed(const Duration(seconds: 6), () {
      if (_askID != null) {
        logger.w('Asked position but no one answered');
        _askID = null;
      }
    });
  }

  void _applyStatus(Message message) async {
    // Not playing the same video, ignore
    if (!isVideoSameWithRoom) return;

    final re = message.text!.split(' ');

    bool canShowSnackBar = true;
    // If apply status is because asking where, then don't show snack bar
    if (_askID != null) canShowSnackBar = false;

    final isPlaying = VideoPlayer().isPlaying.value;
    if (re.first == 'pause' && isPlaying) {
      VideoPlayer().pause();
      if (canShowSnackBar) {
        showSnackBar('${message.user!.name} 暂停了视频');
        canShowSnackBar = false;
      }
    }
    if (re.first == 'play' && !isPlaying) {
      VideoPlayer().play();
      if (canShowSnackBar) {
        showSnackBar('${message.user!.name} 播放了视频');
        canShowSnackBar = false;
      }
    }

    final position = VideoPlayer().position.value;
    final remotePosition = Duration(milliseconds: int.parse(re.last));
    if ((position - remotePosition).inMilliseconds.abs() > 1000) {
      VideoPlayer().seekTo(remotePosition);
      if (canShowSnackBar) {
        showSnackBar('${message.user!.name} 调整了进度');
        canShowSnackBar = false;
      }
    }
  }

  Future<void> _answerPlayStatus(Message message) async {
    if (message.user?.id == Chat().currentUserNotifier.value!.id) {
      return;
    }

    if (_askID == null) {
      await sendPlayerStatus(quoteMessageId: message.id);
    }
  }

  Future<void> _processPlayStatus(Message message) async {
    if (message.user?.id == Chat().currentUserNotifier.value!.id) {
      return;
    }

    final quoteID = message.quotedMessageId;

    if (quoteID != null) {
      // Not answering me
      if (quoteID != _askID) return;

      _applyStatus(message);
      _askID = null;
    } else {
      _applyStatus(message);
    }
  }
}
