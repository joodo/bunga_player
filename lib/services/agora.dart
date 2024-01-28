import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/stream_io.dart';

class Agora {
  Agora(this.appId) {
    _asyncInit();
  }
  final String appId;

  final _engine = createAgoraRtcEngine();
  bool _engineInitialized = false;

  Future<void> _asyncInit() async {
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
    _engineInitialized = true;

    // Logs
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          logger.i("Voice call: Local user uid:${connection.localUid} joined.");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          logger.i("Voice call: Remote user uid:$remoteUid joined.");
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          logger.i(
              "Voice call: Remote user uid:$remoteUid left. Reason: $reason");
        },
      ),
    );
  }

  void registerEventHandler({
    Function(String? channelId, int? localUserId)? onJoinChannelSuccess,
    Function(String? channelId, int? localUserId, int? remoteUserId)?
        onUserJoined,
    Function(String? channelId, int? localUserId, int? remoteUserId)?
        onUserLeft,
  }) {
    // wait 1 second if engine not initialized
    if (!_engineInitialized) {
      Future.delayed(
        const Duration(seconds: 1),
        () => registerEventHandler(
          onJoinChannelSuccess: onJoinChannelSuccess,
          onUserJoined: onUserJoined,
          onUserLeft: onUserLeft,
        ),
      );
      return;
    }

    final handler = RtcEngineEventHandler(
      onJoinChannelSuccess: onJoinChannelSuccess != null
          ? (RtcConnection connection, int elapsed) =>
              onJoinChannelSuccess(connection.channelId, connection.localUid)
          : null,
      onUserJoined: onUserJoined != null
          ? (RtcConnection connection, int remoteUid, int elapsed) =>
              onUserJoined(connection.channelId, connection.localUid, remoteUid)
          : null,
      onUserOffline: onUserLeft != null
          ? (RtcConnection connection, int remoteUid,
                  UserOfflineReasonType reason) =>
              onUserLeft(connection.channelId, connection.localUid, remoteUid)
          : null,
    );
    _engine.registerEventHandler(handler);
  }

  Future setVolume(int volume) async {
    assert(volume >= 0 && volume <= 400);

    // wait 1 second if engine not initialized
    if (!_engineInitialized) {
      return Future.delayed(
        const Duration(seconds: 1),
        () => setVolume(volume),
      );
    }

    await _engine.adjustPlaybackSignalVolume(volume);
  }

  Future joinChannel(VoiceCallChannelData data) async {
    const options = ChannelMediaOptions(
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    );
    return await _engine.joinChannel(
      token: data.token,
      channelId: data.id,
      uid: data.uid,
      options: options,
    );
  }

  Future leaveChannel() {
    return _engine.leaveChannel();
  }
}
