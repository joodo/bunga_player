import 'package:bunga_player/common/logger.dart';
import 'package:bunga_player/common/snack_bar.dart';
import 'package:bunga_player/common/video_controller.dart';
import 'package:bunga_player/secrets/secrets.dart';
import 'package:flutter/foundation.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class IM extends ChangeNotifier {
  final _chatClient = StreamChatClient(
    StreamKey.appKey,
    logLevel: Level.WARNING,
  );

  OwnUser? _user;
  String? get userName => _user?.name;

  Future<bool> login(String userName) async {
    try {
      final userID = userName.hashCode.toString();
      _user = await _chatClient.connectUser(
        User(
          id: userID,
          name: userName,
        ),
        _chatClient.devToken(userID).rawValue,
      );
    } catch (e) {
      logger.e(e);
      return false;
    }
    return true;
  }

  Future<bool> logout() async {
    try {
      await _chatClient.disconnectUser();
    } catch (e) {
      logger.e(e);
      return false;
    }
    return true;
  }

  Channel? _channel;
  List<User>? _watchers;
  List<User>? get watchers => _watchers;
  Future<bool> createOrJoinGroup(String channelID, String channelName) async {
    _channel = _chatClient.channel(
      'livestream',
      id: channelID,
      extraData: {
        'name': channelName,
      },
    );

    try {
      await _channel!.watch();
      final result = await _channel!.query(
        watch: true,
        watchersPagination: const PaginationParams(limit: 100, offset: 0),
      );
      _watchers = result.watchers;
    } catch (e) {
      logger.e(e);
      return false;
    }

    _channel!.on('message.new').listen(_onNewMessage);
    _channel!.on('user.watching.start').listen((event) {
      if (event.user!.id == _user!.id) return;
      _watchers!.add(event.user!);
      notifyListeners();
      showSnackBar('${event.user!.name} 已加入');
    });
    _channel!.on('user.watching.stop').listen((event) {
      _watchers!.removeWhere((element) => element.id == event.user!.id);
      notifyListeners();
      showSnackBar('${event.user!.name} 已离开');
    });

    return true;
  }

  Future<SendMessageResponse> sendMessage(String message) {
    final m = Message(text: message);
    return _channel!.sendMessage(m);
  }

  String? _askID;
  Future<bool> askPosition() async {
    final SendMessageResponse response;
    try {
      response = await sendMessage('where');
    } catch (e) {
      logger.e(e);
      return false;
    }
    _askID = response.message.id;
    return true;
  }

  Future<bool> sendStatus() async {
    try {
      await sendMessage(_statusMessage());
    } catch (e) {
      logger.e(e);
      return false;
    }
    return true;
  }

  String _statusMessage() {
    final controller = VideoController.instance();
    final position = controller.position.value.inMilliseconds;
    final isPlaying = controller.playerStatus.playing;
    return (isPlaying ? 'play at ' : 'pause at ') + position.toString();
  }

  void _onNewMessage(Event event) {
    final userID = event.user!.id;
    if (userID == _user!.id) return;

    final re = event.message!.text!.split(' ');
    void applyStatus() async {
      final controller = VideoController.instance();

      bool canShowSnackBar = true;
      if (_askID != null) canShowSnackBar = false;

      final position = controller.position.value;
      final remotePosition = Duration(milliseconds: int.parse(re.last)) +
          DateTime.now().difference(event.message!.createdAt);
      if ((position - remotePosition).inMilliseconds.abs() > 1000) {
        controller.seekTo(remotePosition);
        if (canShowSnackBar) {
          showSnackBar('${event.user!.name} 调整了进度');
          canShowSnackBar = false;
        }
      }

      final isPlaying = controller.playerStatus.playing;
      if (re.first == 'pause' && isPlaying) {
        controller.pause();
        if (canShowSnackBar) showSnackBar('${event.user!.name} 暂停了视频');
      }
      if (re.first == 'play' && !isPlaying) {
        controller.play();
        if (canShowSnackBar) showSnackBar('${event.user!.name} 播放了视频');
      }
    }

    if (re.first == 'where') {
      final m = Message(
        text: _statusMessage(),
        quotedMessageId: event.message!.id,
      );
      _channel!.sendMessage(m);
      return;
    }

    final quoteID = event.message!.quotedMessageId;
    if (quoteID != null) {
      if (quoteID != _askID) return;

      applyStatus();
      _askID = null;
    } else {
      applyStatus();
    }
  }
}
