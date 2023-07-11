import 'package:bunga_player/models/bili_entry.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/snack_bar.dart';
import 'package:bunga_player/controllers/ui_notifiers.dart';
import 'package:bunga_player/services/tokens.dart';
import 'package:bunga_player/services/video_player.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

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
    try {
      UINotifiers().isBusy.value = true;
      await for (var hintText in loadBiliEntry(BiliEntry.fromHash(videoHash))) {
        UINotifiers().hintText.value = hintText;
      }
    } catch (e) {
      logger.e(e);
    } finally {
      UINotifiers().hintText.value = null;
      UINotifiers().isBusy.value = false;
    }
  }

  Stream<String> loadBiliEntry(BiliEntry biliEntry) async* {
    VideoPlayer().stop();

    yield '正在鬼鬼祟祟……';
    await biliEntry.fetch();
    if (!biliEntry.isHD) {
      showSnackBar('无法获取高清视频');
      logger.w('Bilibili: Cookie of serverless funtion outdated');
    }

    yield '正在收拾客厅……';
    await VideoPlayer().loadBiliVideo(biliEntry);
  }

  bool get isVideoSameWithRoom =>
      Chat().channelExtraDataNotifier.value['hash'] ==
      VideoPlayer().videoHashNotifier.value;

  // About play status
  void sendPlayerStatus({String? quoteMessageId}) {
    // Not playing the same video, ignore
    if (!isVideoSameWithRoom) return;

    final isPlay = VideoPlayer().isPlaying.value;
    final position = VideoPlayer().position.value;

    final messageText =
        '${isPlay ? "play" : "pause"} at ${position.inMilliseconds}';
    Chat().sendMessage(
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
    if (message.user?.id == Tokens().bunga.clientID) {
      return;
    }

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

    final isPlaying = VideoPlayer().isPlaying.value;
    if (re.first == 'pause' && isPlaying) {
      VideoPlayer().isPlaying.value = false;
      if (canShowSnackBar) {
        showSnackBar('${message.user!.name} 暂停了视频');
        canShowSnackBar = false;
        _markRemoteToggle();
      }
    }
    if (re.first == 'play' && !isPlaying) {
      VideoPlayer().isPlaying.value = true;
      if (canShowSnackBar) {
        showSnackBar('${message.user!.name} 播放了视频');
        canShowSnackBar = false;
        _markRemoteToggle();
      }
    }

    final position = VideoPlayer().position.value;
    final remotePosition = Duration(milliseconds: int.parse(re.last));
    if ((position - remotePosition).inMilliseconds.abs() > 1000) {
      VideoPlayer().position.value = remotePosition;
      if (canShowSnackBar) {
        showSnackBar('${message.user!.name} 调整了进度');
        canShowSnackBar = false;
      }
    }
  }

  void _answerPlayStatus(Message message) {
    if (message.user?.id == Tokens().bunga.clientID) {
      return;
    }

    if (_askID == null) {
      sendPlayerStatus(quoteMessageId: message.id);
    }
  }
}
