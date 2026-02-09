import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:bunga_player/bunga_server/models/bunga_server_info.dart';
import 'package:bunga_player/play/service/service.agora.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:bunga_player/utils/models/volume.dart';
import 'package:flutter/material.dart';

import 'client.dart';

enum NoiseSuppressionLevel { none, low, middle, high }

class AgoraClient extends VoiceCallClient {
  final String key;
  final String channelId;
  final String channelToken;

  static Future<AgoraClient?> create(BungaServerInfo info) async {
    if (info.voiceCall == null) return null;

    final client = AgoraClient._(
      key: info.voiceCall!.key,
      channelId: info.channel.id,
      channelToken: info.voiceCall!.channelToken,
    );
    await client._init();

    // Media player
    final playService = getIt.get<PlayService>();
    if (playService is AgoraPlayService) {
      playService.registerEngine(client._engine);
    }

    return client;
  }

  AgoraClient._({
    required this.key,
    required this.channelId,
    required this.channelToken,
  }) {
    // Listeners
    noiseSuppressionLevelNotifier.addListener(() async {
      final level = noiseSuppressionLevelNotifier.value;
      switch (level) {
        case .none:
          await _engine.setAINSMode(
            enabled: false,
            mode: AudioAinsMode.ainsModeAggressive,
          );
        case .low:
          await _engine.setAINSMode(
            enabled: true,
            mode: AudioAinsMode.ainsModeUltralowlatency,
          );
        case .middle:
          await _engine.setAINSMode(
            enabled: true,
            mode: AudioAinsMode.ainsModeBalanced,
          );
        case .high:
          await _engine.setAINSMode(
            enabled: true,
            mode: AudioAinsMode.ainsModeAggressive,
          );
      }
      logger.i('Call: noise suppression set to $level');
    });
    volumeNotifier.addListener(() {
      final volume = volumeNotifier.value;
      final value = volume.mute ? 0 : volume.volume;
      _engine.adjustPlaybackSignalVolume(value * 3); // max 3 times of origin
    });
    micMuteNotifier.addListener(() {
      _engine.muteLocalAudioStream(micMuteNotifier.value);
    });
  }

  final _engine = createAgoraRtcEngine();
  Future<void> _init() async {
    // Engine
    await _engine.initialize(
      RtcEngineContext(
        appId: key,
        logConfig: const LogConfig(level: LogLevel.logLevelWarn),
      ),
    );

    // Events
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          logger.i('Voice call: Local user uid:${connection.localUid} joined.');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          logger.i('Voice call: Remote user uid:$remoteUid joined.');
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              if (connection.localUid == remoteUid) return;
              logger.i(
                'Voice call: Remote user uid:$remoteUid left. Reason: $reason.',
              );
            },
      ),
    );

    // Profile
    await _engine.setAudioProfile(
      profile: AudioProfileType.audioProfileSpeechStandard,
      scenario: AudioScenarioType.audioScenarioChatroom,
    );

    if (kIsDesktop) {
      inputDeviceNotifier.value = await _engine
          .getAudioDeviceManager()
          .getRecordingDevice();
      inputDeviceNotifier.addListener(() {
        _engine.getAudioDeviceManager().setRecordingDevice(
          inputDeviceNotifier.value,
        );
      });
    }
  }

  // Noise suppress
  final noiseSuppressionLevelNotifier = ValueNotifier<NoiseSuppressionLevel>(
    NoiseSuppressionLevel.high,
  );

  // Volume
  @override
  final volumeNotifier = ValueNotifier<Volume>(Volume(volume: 100));

  // Mic
  @override
  final micMuteNotifier = ValueNotifier<bool>(false);

  // Devices
  Future<List<AudioDeviceInfo>> getAvailableInputDevices() {
    return _engine.getAudioDeviceManager().enumerateRecordingDevices();
  }

  final inputDeviceNotifier = ValueNotifier<String>('');

  // Channel
  @override
  Future<void> joinChannel({required String userId}) async {
    const options = ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );

    return _engine.joinChannel(
      channelId: channelId,
      uid: _uidFromUserId(userId),
      token: channelToken,
      options: options,
    );
  }

  int _uidFromUserId(String userId) {
    int hash = 5381;
    for (int i = 0; i < userId.length; i++) {
      hash = ((hash << 5) + hash) + userId.codeUnitAt(i);
    }
    return hash & 0x7FFFFFFF;
  }

  @override
  Future<void> leaveChannel() {
    return _engine.leaveChannel();
  }
}
