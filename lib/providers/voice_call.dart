import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/providers/current_channel.dart';
import 'package:bunga_player/providers/current_user.dart';
import 'package:bunga_player/services/agora.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/providers/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

enum CallStatus {
  none,
  callIn,
  callOut,
  calling,
}

class VoiceCall extends ChangeNotifier {
  VoiceCall(Locator read)
      : _currentChannel = read<CurrentChannel>(),
        _currentUser = read<CurrentUser>(),
        _showSnackBar = read<Toast>().show {
    // Call Ring
    addListener(() {
      if (callStatus == CallStatus.callIn || callStatus == CallStatus.callOut) {
        _callRinger.resume();
      } else {
        _callRinger.stop();
      }
    });

    // Listen to remote
    final agoraService = getService<Agora>();
    agoraService.registerEventHandler(
      onUserJoined: (channelId, localUserId, remoteUserId) {
        assert(remoteUserId != null);
        if (localUserId != remoteUserId) {
          _talkingUsers.add(remoteUserId!);
        }
      },
      onUserLeft: (channelId, localUserId, remoteUserId) {
        _talkingUsers.remove(remoteUserId);
        if (_talkingUsers.isEmpty) {
          _showSnackBar('对方已挂断');
          hangUp();
        }
      },
    );

    // Volume

    volume.addListener(() {
      mute.value = false;
      agoraService.setVolume(volume.value);
      getService<Preferences>().set('call_volume', volume.value);
    });
    mute.addListener(
      () {
        mute.value
            ? agoraService.setVolume(0)
            : agoraService.setVolume(volume.value);
      },
    );
    _loadSavedVolume();

    // Channel
    _currentChannel.addListener(() {
      if (_currentChannel.isEmpty) {
        // Leaving room
        _watcherLeaveSubscription?.cancel();
        _messageSubscription?.cancel();
        hangUp();
      } else {
        // Joining room
        _watcherLeaveSubscription =
            _currentChannel.watcherLeaveEventStream.listen((user) {
          if (callStatus == CallStatus.callOut) {
            _myCallAskingIsRejectedBy(user);
          }
        });

        // Receiving message
        _messageSubscription = _currentChannel.messageStream.listen((message) {
          if (message?.text?.split(' ').first != 'call') return;

          if (message?.user?.id == _currentUser.id) return;

          _dealMessage(message!);
        });
      }
    });
  }

  final void Function(String text) _showSnackBar;

  final CurrentUser _currentUser;
  final CurrentChannel _currentChannel;
  StreamSubscription? _watcherLeaveSubscription, _messageSubscription;

  // Calling
  CallStatus __callStatus = CallStatus.none;
  CallStatus get callStatus => __callStatus;
  set _callStatus(CallStatus status) {
    if (__callStatus == status) return;
    __callStatus = status;
    notifyListeners();
  }

  final _callRinger = AudioPlayer()..setSource(AssetSource('sounds/call.wav'));

  String? _callAskingMessageId;
  List<String>? _myCallAskingHopeList;
  final _talkingUsers = <int>{};
  late final _callAskingTimeOutTimer = RestartableTimer(
    const Duration(seconds: 30),
    () {
      _showSnackBar('无人接听');
      cancelAsking();
    },
  )..cancel();

  void _dealMessage(Message message) {
    final content = message.text?.split(' ')[1];
    switch (content) {
      // someone ask for call
      case 'ask':
        switch (callStatus) {
          // Has call in
          case CallStatus.none:
            _callStatus = CallStatus.callIn;
            _callAskingMessageId = message.id;
            break;

          // Already has call in, no need to deal, current caller will accept
          case CallStatus.callIn:
            break;

          // Some one also want call when I'm calling out, so answer him
          case CallStatus.callOut:
            final m = Message(
              text: 'call yes',
              quotedMessageId: message.id,
            );
            _currentChannel
                .send(m)
                .then((value) => _myCallAskingHasBeenAccepted());
            break;

          // Some one want to join when we are calling, answer him
          case CallStatus.calling:
            final m = Message(
              text: 'call yes',
              quotedMessageId: message.id,
            );
            _currentChannel.send(m);
            break;
        }
        break;

      // caller canceled asking
      case 'cancel':
        if (callStatus == CallStatus.callIn &&
            message.quotedMessageId == _callAskingMessageId) {
          _callStatus = CallStatus.none;
          _callAskingMessageId = null;
        }
        break;

      case 'yes':
        if (callStatus == CallStatus.callOut &&
            message.quotedMessageId == _callAskingMessageId) {
          _myCallAskingHasBeenAccepted();
        }
        break;

      case 'no':
        if (callStatus == CallStatus.callOut &&
            message.quotedMessageId == _callAskingMessageId) {
          _myCallAskingIsRejectedBy(message.user!);
        }
        break;

      default:
        logger.w('Unknown call message: $content');
    }
  }

  Future<void> _myCallAskingHasBeenAccepted() {
    _callStatus = CallStatus.calling;
    _callAskingMessageId = null;
    _myCallAskingHopeList = null;
    _callAskingTimeOutTimer.cancel();

    return _joinCallChannel();
  }

  void _myCallAskingIsRejectedBy(User user) {
    assert(_myCallAskingHopeList != null);
    _myCallAskingHopeList!.remove(user.id);

    logger.i(
        '${user.id} rejected call asking or leaved, hope list: $_myCallAskingHopeList');

    if (_myCallAskingHopeList!.isEmpty) {
      _showSnackBar('呼叫已被拒绝');
      cancelAsking();
    }
  }

  Future startAsking() async {
    _callStatus = CallStatus.callOut;
    var message = Message(text: 'call ask');
    await _currentChannel.send(message);

    _callAskingMessageId = message.id;
    _myCallAskingHopeList =
        _currentChannel.watchersNotifier.value.map((u) => u.id).toList();
    _myCallAskingHopeList!.remove(_currentUser.id);
    logger.i('start call asking, hope list: $_myCallAskingHopeList');

    _callAskingTimeOutTimer.reset();
  }

  void cancelAsking() {
    _currentChannel.send(Message(
      text: 'call cancel',
      quotedMessageId: _callAskingMessageId,
    ));
    _myCallAskingHopeList = null;
    _callAskingMessageId = null;
    _callStatus = CallStatus.none;
    _callAskingTimeOutTimer.cancel();
  }

  void rejectAsking() {
    _currentChannel.send(Message(
      text: 'call no',
      quotedMessageId: _callAskingMessageId,
    ));
    _callAskingMessageId = null;
    _callStatus = CallStatus.none;
  }

  void acceptAsking() {
    _currentChannel.send(Message(
      text: 'call yes',
      quotedMessageId: _callAskingMessageId,
    ));
    _callAskingMessageId = null;
    _callStatus = CallStatus.calling;

    _joinCallChannel();
  }

  Future<void> hangUp() async {
    if (callStatus == CallStatus.none) return;
    _callStatus = CallStatus.none;
    AudioPlayer().play(AssetSource('sounds/hang_up.wav'));

    final agoraService = getService<Agora>();
    await agoraService.leaveChannel();
  }

  Future<void> _joinCallChannel() async {
    final channelData = await _currentChannel.createVoiceCall();
    logger.i('try join voice channel: $channelData');

    final agoraService = getService<Agora>();
    await agoraService.joinChannel(channelData);
  }

  // Volume
  final volume = ValueNotifier<int>(100); // range 0 ~ 400
  final mute = ValueNotifier<bool>(false);
  void _loadSavedVolume() {
    final savedVolume = getService<Preferences>().get<int>('call_volume');
    if (savedVolume != null) volume.value = savedVolume;
  }
}
