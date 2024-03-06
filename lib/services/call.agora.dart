import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/services/chat.stream_io.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/services/services.dart';

import 'call.dart';

class Agora implements CallService {
  Agora(String appId) {
    _asyncInit(appId);
  }

  final _engine = createAgoraRtcEngine();

  Future<void> setNoiseSuppression(NoiseSuppressionLevel level) {
    logger.i('Call: noise suppression set to $level');
    switch (level) {
      case NoiseSuppressionLevel.none:
        return _engine.setAINSMode(
          enabled: false,
          mode: AudioAinsMode.ainsModeAggressive,
        );
      case NoiseSuppressionLevel.low:
        return _engine.setAINSMode(
          enabled: true,
          mode: AudioAinsMode.ainsModeUltralowlatency,
        );
      case NoiseSuppressionLevel.middle:
        return _engine.setAINSMode(
          enabled: true,
          mode: AudioAinsMode.ainsModeBalanced,
        );
      case NoiseSuppressionLevel.high:
        return _engine.setAINSMode(
          enabled: true,
          mode: AudioAinsMode.ainsModeAggressive,
        );
    }
  }

  Future<void> _asyncInit(String appId) async {
    // Mic permission
    /*
    try {
      await [Permission.microphone].request();
    } catch (e) {
      logger.e(e);
    }
    */

    // Engine
    await _engine.initialize(RtcEngineContext(
      appId: appId,
      logConfig: const LogConfig(level: LogLevel.logLevelWarn),
    ));

    // Profile
    _engine.setAudioProfile(
      profile: AudioProfileType.audioProfileSpeechStandard,
      scenario: AudioScenarioType.audioScenarioChatroom,
    );

    // Noise suppression
    setNoiseSuppression(NoiseSuppressionLevel.high);

    // Events
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          logger.i('Voice call: Local user uid:${connection.localUid} joined.');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          if (connection.localUid == remoteUid) return;
          _talkersID.add(remoteUid);
          _talkersCountStreamController.add(_talkersID.length);
          logger.i(
              'Voice call: Remote user uid:$remoteUid joined.\nCurrent Talkers: $_talkersID');
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          if (connection.localUid == remoteUid) return;
          _talkersID.remove(remoteUid);
          _talkersCountStreamController.add(_talkersID.length);
          logger.i(
              'Voice call: Remote user uid:$remoteUid left. Reason: $reason.\nCurrent Talkers: $_talkersID');
        },
      ),
    );
  }

  // Talkers
  final _talkersCountStreamController = StreamController<int>.broadcast();
  final _talkersID = <int>{};

  // Volume
  @override
  Future<void> setVolume(double percent) async {
    assert(percent >= 0 && percent <= 1);

    await _engine.adjustPlaybackSignalVolume((300 * percent).toInt());
  }

  // Mic
  @override
  Future<void> setMuteMic(bool mute) {
    return _engine.muteLocalAudioStream(mute);
  }

  // Channel
  @override
  Future<Stream<int>> joinChannel() async {
    final streamService = getIt<ChatService>() as StreamIO;
    final (cid, uid, token) = await streamService.getAgoraChannelData();

    const options = ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    await _engine.joinChannel(
      channelId: cid,
      uid: uid,
      token: token,
      options: options,
    );

    return _talkersCountStreamController.stream;
  }

  @override
  Future<void> leaveChannel() {
    return _engine.leaveChannel();
  }
}
