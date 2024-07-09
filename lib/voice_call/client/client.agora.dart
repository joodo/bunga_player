import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bunga_player/bunga_server/client.dart';
import 'package:bunga_player/services/logger.dart';

import '../providers.dart';
import 'client.dart';

class AgoraClient extends VoiceCallClient {
  final BungaClient _bungaClient;

  AgoraClient(
    this._bungaClient, {
    double? volume,
    NoiseSuppressionLevel? noiseSuppressionLevel,
  })  : _volumeCache = volume,
        _noiseSuppressionLevelCache = noiseSuppressionLevel {
    _asyncInit(_bungaClient.agoraClientAppKey);
  }

  final _engine = createAgoraRtcEngine();

  NoiseSuppressionLevel? _noiseSuppressionLevelCache;
  Future<void> setNoiseSuppression(NoiseSuppressionLevel level) async {
    if (!_initiated) {
      _noiseSuppressionLevelCache = level;
      return;
    }

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

  bool _initiated = false;
  Future<void> _asyncInit(String appId) async {
    // Engine
    await _engine.initialize(RtcEngineContext(
      appId: appId,
      logConfig: const LogConfig(level: LogLevel.logLevelWarn),
    ));

    // Events
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          logger.i('Voice call: Local user uid:${connection.localUid} joined.');
          AudioPlayer().play(
            AssetSource('sounds/user_speak.wav'),
            mode: PlayerMode.lowLatency,
          );
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          logger.i('Voice call: Remote user uid:$remoteUid joined.');
        },
        onUserOffline: (
          RtcConnection connection,
          int remoteUid,
          UserOfflineReasonType reason,
        ) {
          if (connection.localUid == remoteUid) return;
          logger.i(
              'Voice call: Remote user uid:$remoteUid left. Reason: $reason.');
        },
      ),
    );

    // Profile
    await _engine.setAudioProfile(
      profile: AudioProfileType.audioProfileSpeechStandard,
      scenario: AudioScenarioType.audioScenarioChatroom,
    );

    _initiated = true;
    if (_noiseSuppressionLevelCache != null) {
      setNoiseSuppression(_noiseSuppressionLevelCache!);
      _noiseSuppressionLevelCache = null;
    }
    if (_volumeCache != null) {
      setVolume(_volumeCache!);
      _volumeCache = null;
    }
  }

  // Volume
  double? _volumeCache;
  @override
  Future<void> setVolume(double percent) async {
    assert(percent >= 0 && percent <= 1);

    if (!_initiated) {
      _volumeCache = percent;
      return;
    }

    await _engine.adjustPlaybackSignalVolume((300 * percent).toInt());
  }

  // Mic
  @override
  Future<void> setMuteMic(bool mute) {
    return _engine.muteLocalAudioStream(mute);
  }

  // Channel
  @override
  Future<void> joinChannel({
    required String userId,
    required String channelId,
  }) async {
    final uid = userId.hashCode;

    final tokenResponse = await _bungaClient.post('agora/token', {
      'uid': uid,
      'channel': channelId,
    });
    final token = jsonDecode(tokenResponse)['token'];

    const options = ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    return _engine.joinChannel(
      channelId: channelId,
      uid: uid,
      token: token,
      options: options,
    );
  }

  @override
  Future<void> leaveChannel() {
    return _engine.leaveChannel();
  }
}
