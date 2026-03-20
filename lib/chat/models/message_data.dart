import 'package:flutter/painting.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:bunga_player/play/models/video_record.dart';

import 'user.dart';

part 'message_data.freezed.dart';
part 'message_data.g.dart';

// Play sync enums
enum ChannelPlayStatus {
  paused,
  pending,
  playing;

  bool get isPlaying => this == playing;
}

// Voice call enums
enum CallAction { call, accept, reject, cancel }

enum TalkStatus { start, end }

@Freezed(
  unionKey: 'code',
  unionValueCase: FreezedUnionCase.kebab,
  fallbackUnion: 'unknown',
)
sealed class MessageData with _$MessageData {
  /// Send when asking what's playing
  const factory MessageData.whatsOn() = WhatsOnMessageData;

  /// Receive when answering what's playing
  const factory MessageData.nowPlaying({
    required VideoRecord record,
    required User sharer,
  }) = NowPlayingMessageData;

  /// Send when join watching
  const factory MessageData.joinIn({
    required User user,
    StartProjectionMessageData? myShare,
  }) = JoinInMessageData;

  /// Receive when join in room
  const factory MessageData.hereAre({
    required List<User> watchers,
    required List<String> buffering,
    required List<String> talking,
  }) = HereAreMessageData;

  /// Send/receive when sharing video
  const factory MessageData.startProjection({
    required VideoRecord videoRecord,
    @Default(Duration.zero) Duration position,
  }) = StartProjectionMessageData;

  /// Receive when server reset cache
  const factory MessageData.reset() = ResetMessageData;

  /// Receive when someone join watching
  const factory MessageData.aloha() = AlohaMessageData;

  /// Send when leave watching
  const factory MessageData.bye() = ByeMessageData;

  /// Receive when server not recognize client
  const factory MessageData.whoAreYou() = WhoAreYouMessageData;

  /// Send status as heartbeat
  const factory MessageData.clientStatus({required bool isPending}) =
      ClientStatusMessageData;

  /// Receive channel status as heartbeat
  const factory MessageData.channelStatus({
    required List<String> watcherIds,
    required List<String> readyIds,
    required Duration position,
    required ChannelPlayStatus playStatus,
  }) = ChannelStatusMessageData;

  /// Send/Receive when start play
  const factory MessageData.play() = PlayMessageData;

  /// Send/Receive when pause
  const factory MessageData.pause({required Duration position}) =
      PauseMessageData;

  /// Send when seek video
  const factory MessageData.seek({required Duration position}) =
      SeekMessageData;

  /// Send when video finished
  const factory MessageData.playFinished() = PlayFinishedMessageData;

  /// Send when sharing subtitle
  const factory MessageData.shareSub({
    required String url,
    required String title,
  }) = ShareSubMessageData;

  /// Send when negotiating calling
  const factory MessageData.call({required CallAction action}) =
      CallMessageData;

  /// Send when join / leave talking
  const factory MessageData.talkStatus({required TalkStatus status}) =
      TalkStatusMessageData;

  /// Send popmoji
  const factory MessageData.popmoji({required String popmojiCode}) =
      PopmojiMessageData;

  /// Send danmaku
  const factory MessageData.danmaku({required String message}) =
      DanmakuMessageData;

  /// Sparking
  const factory MessageData.spark({
    required String emoji,
    @JsonKey(
      fromJson: _fractionalOffsetFromJson,
      toJson: _fractionalOffsetToJson,
    )
    required FractionalOffset fraction,
  }) = SparkMessageData;

  const factory MessageData.unknown() = UnknownMessageData;

  factory MessageData.fromJson(Map<String, dynamic> json) =>
      _$MessageDataFromJson(json);
}

FractionalOffset _fractionalOffsetFromJson(List<dynamic> json) =>
    FractionalOffset(json[0], json[1]);

List<double> _fractionalOffsetToJson(FractionalOffset offset) => [
  offset.dx,
  offset.dy,
];
