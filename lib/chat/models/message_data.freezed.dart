// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
MessageData _$MessageDataFromJson(
  Map<String, dynamic> json
) {
        switch (json['code']) {
                  case 'whats-on':
          return WhatsOnMessageData.fromJson(
            json
          );
                case 'now-playing':
          return NowPlayingMessageData.fromJson(
            json
          );
                case 'join-in':
          return JoinInMessageData.fromJson(
            json
          );
                case 'here-are':
          return HereAreMessageData.fromJson(
            json
          );
                case 'start-projection':
          return StartProjectionMessageData.fromJson(
            json
          );
                case 'reset':
          return ResetMessageData.fromJson(
            json
          );
                case 'aloha':
          return AlohaMessageData.fromJson(
            json
          );
                case 'bye':
          return ByeMessageData.fromJson(
            json
          );
                case 'who-are-you':
          return WhoAreYouMessageData.fromJson(
            json
          );
                case 'client-status':
          return ClientStatusMessageData.fromJson(
            json
          );
                case 'channel-status':
          return ChannelStatusMessageData.fromJson(
            json
          );
                case 'play':
          return PlayMessageData.fromJson(
            json
          );
                case 'pause':
          return PauseMessageData.fromJson(
            json
          );
                case 'seek':
          return SeekMessageData.fromJson(
            json
          );
                case 'play-finished':
          return PlayFinishedMessageData.fromJson(
            json
          );
                case 'share-sub':
          return ShareSubMessageData.fromJson(
            json
          );
                case 'call':
          return CallMessageData.fromJson(
            json
          );
                case 'talk-status':
          return TalkStatusMessageData.fromJson(
            json
          );
                case 'popmoji':
          return PopmojiMessageData.fromJson(
            json
          );
                case 'danmaku':
          return DanmakuMessageData.fromJson(
            json
          );
                case 'spark':
          return SparkMessageData.fromJson(
            json
          );
        
          default:
            return UnknownMessageData.fromJson(
  json
);
        }
      
}

/// @nodoc
mixin _$MessageData {



  /// Serializes this MessageData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageData);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageData()';
}


}

/// @nodoc
class $MessageDataCopyWith<$Res>  {
$MessageDataCopyWith(MessageData _, $Res Function(MessageData) __);
}


/// Adds pattern-matching-related methods to [MessageData].
extension MessageDataPatterns on MessageData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( WhatsOnMessageData value)?  whatsOn,TResult Function( NowPlayingMessageData value)?  nowPlaying,TResult Function( JoinInMessageData value)?  joinIn,TResult Function( HereAreMessageData value)?  hereAre,TResult Function( StartProjectionMessageData value)?  startProjection,TResult Function( ResetMessageData value)?  reset,TResult Function( AlohaMessageData value)?  aloha,TResult Function( ByeMessageData value)?  bye,TResult Function( WhoAreYouMessageData value)?  whoAreYou,TResult Function( ClientStatusMessageData value)?  clientStatus,TResult Function( ChannelStatusMessageData value)?  channelStatus,TResult Function( PlayMessageData value)?  play,TResult Function( PauseMessageData value)?  pause,TResult Function( SeekMessageData value)?  seek,TResult Function( PlayFinishedMessageData value)?  playFinished,TResult Function( ShareSubMessageData value)?  shareSub,TResult Function( CallMessageData value)?  call,TResult Function( TalkStatusMessageData value)?  talkStatus,TResult Function( PopmojiMessageData value)?  popmoji,TResult Function( DanmakuMessageData value)?  danmaku,TResult Function( SparkMessageData value)?  spark,TResult Function( UnknownMessageData value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case WhatsOnMessageData() when whatsOn != null:
return whatsOn(_that);case NowPlayingMessageData() when nowPlaying != null:
return nowPlaying(_that);case JoinInMessageData() when joinIn != null:
return joinIn(_that);case HereAreMessageData() when hereAre != null:
return hereAre(_that);case StartProjectionMessageData() when startProjection != null:
return startProjection(_that);case ResetMessageData() when reset != null:
return reset(_that);case AlohaMessageData() when aloha != null:
return aloha(_that);case ByeMessageData() when bye != null:
return bye(_that);case WhoAreYouMessageData() when whoAreYou != null:
return whoAreYou(_that);case ClientStatusMessageData() when clientStatus != null:
return clientStatus(_that);case ChannelStatusMessageData() when channelStatus != null:
return channelStatus(_that);case PlayMessageData() when play != null:
return play(_that);case PauseMessageData() when pause != null:
return pause(_that);case SeekMessageData() when seek != null:
return seek(_that);case PlayFinishedMessageData() when playFinished != null:
return playFinished(_that);case ShareSubMessageData() when shareSub != null:
return shareSub(_that);case CallMessageData() when call != null:
return call(_that);case TalkStatusMessageData() when talkStatus != null:
return talkStatus(_that);case PopmojiMessageData() when popmoji != null:
return popmoji(_that);case DanmakuMessageData() when danmaku != null:
return danmaku(_that);case SparkMessageData() when spark != null:
return spark(_that);case UnknownMessageData() when unknown != null:
return unknown(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( WhatsOnMessageData value)  whatsOn,required TResult Function( NowPlayingMessageData value)  nowPlaying,required TResult Function( JoinInMessageData value)  joinIn,required TResult Function( HereAreMessageData value)  hereAre,required TResult Function( StartProjectionMessageData value)  startProjection,required TResult Function( ResetMessageData value)  reset,required TResult Function( AlohaMessageData value)  aloha,required TResult Function( ByeMessageData value)  bye,required TResult Function( WhoAreYouMessageData value)  whoAreYou,required TResult Function( ClientStatusMessageData value)  clientStatus,required TResult Function( ChannelStatusMessageData value)  channelStatus,required TResult Function( PlayMessageData value)  play,required TResult Function( PauseMessageData value)  pause,required TResult Function( SeekMessageData value)  seek,required TResult Function( PlayFinishedMessageData value)  playFinished,required TResult Function( ShareSubMessageData value)  shareSub,required TResult Function( CallMessageData value)  call,required TResult Function( TalkStatusMessageData value)  talkStatus,required TResult Function( PopmojiMessageData value)  popmoji,required TResult Function( DanmakuMessageData value)  danmaku,required TResult Function( SparkMessageData value)  spark,required TResult Function( UnknownMessageData value)  unknown,}){
final _that = this;
switch (_that) {
case WhatsOnMessageData():
return whatsOn(_that);case NowPlayingMessageData():
return nowPlaying(_that);case JoinInMessageData():
return joinIn(_that);case HereAreMessageData():
return hereAre(_that);case StartProjectionMessageData():
return startProjection(_that);case ResetMessageData():
return reset(_that);case AlohaMessageData():
return aloha(_that);case ByeMessageData():
return bye(_that);case WhoAreYouMessageData():
return whoAreYou(_that);case ClientStatusMessageData():
return clientStatus(_that);case ChannelStatusMessageData():
return channelStatus(_that);case PlayMessageData():
return play(_that);case PauseMessageData():
return pause(_that);case SeekMessageData():
return seek(_that);case PlayFinishedMessageData():
return playFinished(_that);case ShareSubMessageData():
return shareSub(_that);case CallMessageData():
return call(_that);case TalkStatusMessageData():
return talkStatus(_that);case PopmojiMessageData():
return popmoji(_that);case DanmakuMessageData():
return danmaku(_that);case SparkMessageData():
return spark(_that);case UnknownMessageData():
return unknown(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( WhatsOnMessageData value)?  whatsOn,TResult? Function( NowPlayingMessageData value)?  nowPlaying,TResult? Function( JoinInMessageData value)?  joinIn,TResult? Function( HereAreMessageData value)?  hereAre,TResult? Function( StartProjectionMessageData value)?  startProjection,TResult? Function( ResetMessageData value)?  reset,TResult? Function( AlohaMessageData value)?  aloha,TResult? Function( ByeMessageData value)?  bye,TResult? Function( WhoAreYouMessageData value)?  whoAreYou,TResult? Function( ClientStatusMessageData value)?  clientStatus,TResult? Function( ChannelStatusMessageData value)?  channelStatus,TResult? Function( PlayMessageData value)?  play,TResult? Function( PauseMessageData value)?  pause,TResult? Function( SeekMessageData value)?  seek,TResult? Function( PlayFinishedMessageData value)?  playFinished,TResult? Function( ShareSubMessageData value)?  shareSub,TResult? Function( CallMessageData value)?  call,TResult? Function( TalkStatusMessageData value)?  talkStatus,TResult? Function( PopmojiMessageData value)?  popmoji,TResult? Function( DanmakuMessageData value)?  danmaku,TResult? Function( SparkMessageData value)?  spark,TResult? Function( UnknownMessageData value)?  unknown,}){
final _that = this;
switch (_that) {
case WhatsOnMessageData() when whatsOn != null:
return whatsOn(_that);case NowPlayingMessageData() when nowPlaying != null:
return nowPlaying(_that);case JoinInMessageData() when joinIn != null:
return joinIn(_that);case HereAreMessageData() when hereAre != null:
return hereAre(_that);case StartProjectionMessageData() when startProjection != null:
return startProjection(_that);case ResetMessageData() when reset != null:
return reset(_that);case AlohaMessageData() when aloha != null:
return aloha(_that);case ByeMessageData() when bye != null:
return bye(_that);case WhoAreYouMessageData() when whoAreYou != null:
return whoAreYou(_that);case ClientStatusMessageData() when clientStatus != null:
return clientStatus(_that);case ChannelStatusMessageData() when channelStatus != null:
return channelStatus(_that);case PlayMessageData() when play != null:
return play(_that);case PauseMessageData() when pause != null:
return pause(_that);case SeekMessageData() when seek != null:
return seek(_that);case PlayFinishedMessageData() when playFinished != null:
return playFinished(_that);case ShareSubMessageData() when shareSub != null:
return shareSub(_that);case CallMessageData() when call != null:
return call(_that);case TalkStatusMessageData() when talkStatus != null:
return talkStatus(_that);case PopmojiMessageData() when popmoji != null:
return popmoji(_that);case DanmakuMessageData() when danmaku != null:
return danmaku(_that);case SparkMessageData() when spark != null:
return spark(_that);case UnknownMessageData() when unknown != null:
return unknown(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  whatsOn,TResult Function( VideoRecord record,  User sharer)?  nowPlaying,TResult Function( User user,  StartProjectionMessageData? myShare)?  joinIn,TResult Function( List<User> watchers,  List<String> buffering,  List<String> talking)?  hereAre,TResult Function( VideoRecord videoRecord,  Duration position)?  startProjection,TResult Function()?  reset,TResult Function()?  aloha,TResult Function()?  bye,TResult Function()?  whoAreYou,TResult Function( bool isPending)?  clientStatus,TResult Function( List<String> watcherIds,  List<String> readyIds,  Duration position,  ChannelPlayStatus playStatus)?  channelStatus,TResult Function()?  play,TResult Function( Duration position)?  pause,TResult Function( Duration position)?  seek,TResult Function()?  playFinished,TResult Function( String url,  String title)?  shareSub,TResult Function( CallAction action)?  call,TResult Function( TalkStatus status)?  talkStatus,TResult Function( String popmojiCode)?  popmoji,TResult Function( String message)?  danmaku,TResult Function( String emoji, @JsonKey(fromJson: _fractionalOffsetFromJson, toJson: _fractionalOffsetToJson)  FractionalOffset fraction)?  spark,TResult Function()?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case WhatsOnMessageData() when whatsOn != null:
return whatsOn();case NowPlayingMessageData() when nowPlaying != null:
return nowPlaying(_that.record,_that.sharer);case JoinInMessageData() when joinIn != null:
return joinIn(_that.user,_that.myShare);case HereAreMessageData() when hereAre != null:
return hereAre(_that.watchers,_that.buffering,_that.talking);case StartProjectionMessageData() when startProjection != null:
return startProjection(_that.videoRecord,_that.position);case ResetMessageData() when reset != null:
return reset();case AlohaMessageData() when aloha != null:
return aloha();case ByeMessageData() when bye != null:
return bye();case WhoAreYouMessageData() when whoAreYou != null:
return whoAreYou();case ClientStatusMessageData() when clientStatus != null:
return clientStatus(_that.isPending);case ChannelStatusMessageData() when channelStatus != null:
return channelStatus(_that.watcherIds,_that.readyIds,_that.position,_that.playStatus);case PlayMessageData() when play != null:
return play();case PauseMessageData() when pause != null:
return pause(_that.position);case SeekMessageData() when seek != null:
return seek(_that.position);case PlayFinishedMessageData() when playFinished != null:
return playFinished();case ShareSubMessageData() when shareSub != null:
return shareSub(_that.url,_that.title);case CallMessageData() when call != null:
return call(_that.action);case TalkStatusMessageData() when talkStatus != null:
return talkStatus(_that.status);case PopmojiMessageData() when popmoji != null:
return popmoji(_that.popmojiCode);case DanmakuMessageData() when danmaku != null:
return danmaku(_that.message);case SparkMessageData() when spark != null:
return spark(_that.emoji,_that.fraction);case UnknownMessageData() when unknown != null:
return unknown();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  whatsOn,required TResult Function( VideoRecord record,  User sharer)  nowPlaying,required TResult Function( User user,  StartProjectionMessageData? myShare)  joinIn,required TResult Function( List<User> watchers,  List<String> buffering,  List<String> talking)  hereAre,required TResult Function( VideoRecord videoRecord,  Duration position)  startProjection,required TResult Function()  reset,required TResult Function()  aloha,required TResult Function()  bye,required TResult Function()  whoAreYou,required TResult Function( bool isPending)  clientStatus,required TResult Function( List<String> watcherIds,  List<String> readyIds,  Duration position,  ChannelPlayStatus playStatus)  channelStatus,required TResult Function()  play,required TResult Function( Duration position)  pause,required TResult Function( Duration position)  seek,required TResult Function()  playFinished,required TResult Function( String url,  String title)  shareSub,required TResult Function( CallAction action)  call,required TResult Function( TalkStatus status)  talkStatus,required TResult Function( String popmojiCode)  popmoji,required TResult Function( String message)  danmaku,required TResult Function( String emoji, @JsonKey(fromJson: _fractionalOffsetFromJson, toJson: _fractionalOffsetToJson)  FractionalOffset fraction)  spark,required TResult Function()  unknown,}) {final _that = this;
switch (_that) {
case WhatsOnMessageData():
return whatsOn();case NowPlayingMessageData():
return nowPlaying(_that.record,_that.sharer);case JoinInMessageData():
return joinIn(_that.user,_that.myShare);case HereAreMessageData():
return hereAre(_that.watchers,_that.buffering,_that.talking);case StartProjectionMessageData():
return startProjection(_that.videoRecord,_that.position);case ResetMessageData():
return reset();case AlohaMessageData():
return aloha();case ByeMessageData():
return bye();case WhoAreYouMessageData():
return whoAreYou();case ClientStatusMessageData():
return clientStatus(_that.isPending);case ChannelStatusMessageData():
return channelStatus(_that.watcherIds,_that.readyIds,_that.position,_that.playStatus);case PlayMessageData():
return play();case PauseMessageData():
return pause(_that.position);case SeekMessageData():
return seek(_that.position);case PlayFinishedMessageData():
return playFinished();case ShareSubMessageData():
return shareSub(_that.url,_that.title);case CallMessageData():
return call(_that.action);case TalkStatusMessageData():
return talkStatus(_that.status);case PopmojiMessageData():
return popmoji(_that.popmojiCode);case DanmakuMessageData():
return danmaku(_that.message);case SparkMessageData():
return spark(_that.emoji,_that.fraction);case UnknownMessageData():
return unknown();}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  whatsOn,TResult? Function( VideoRecord record,  User sharer)?  nowPlaying,TResult? Function( User user,  StartProjectionMessageData? myShare)?  joinIn,TResult? Function( List<User> watchers,  List<String> buffering,  List<String> talking)?  hereAre,TResult? Function( VideoRecord videoRecord,  Duration position)?  startProjection,TResult? Function()?  reset,TResult? Function()?  aloha,TResult? Function()?  bye,TResult? Function()?  whoAreYou,TResult? Function( bool isPending)?  clientStatus,TResult? Function( List<String> watcherIds,  List<String> readyIds,  Duration position,  ChannelPlayStatus playStatus)?  channelStatus,TResult? Function()?  play,TResult? Function( Duration position)?  pause,TResult? Function( Duration position)?  seek,TResult? Function()?  playFinished,TResult? Function( String url,  String title)?  shareSub,TResult? Function( CallAction action)?  call,TResult? Function( TalkStatus status)?  talkStatus,TResult? Function( String popmojiCode)?  popmoji,TResult? Function( String message)?  danmaku,TResult? Function( String emoji, @JsonKey(fromJson: _fractionalOffsetFromJson, toJson: _fractionalOffsetToJson)  FractionalOffset fraction)?  spark,TResult? Function()?  unknown,}) {final _that = this;
switch (_that) {
case WhatsOnMessageData() when whatsOn != null:
return whatsOn();case NowPlayingMessageData() when nowPlaying != null:
return nowPlaying(_that.record,_that.sharer);case JoinInMessageData() when joinIn != null:
return joinIn(_that.user,_that.myShare);case HereAreMessageData() when hereAre != null:
return hereAre(_that.watchers,_that.buffering,_that.talking);case StartProjectionMessageData() when startProjection != null:
return startProjection(_that.videoRecord,_that.position);case ResetMessageData() when reset != null:
return reset();case AlohaMessageData() when aloha != null:
return aloha();case ByeMessageData() when bye != null:
return bye();case WhoAreYouMessageData() when whoAreYou != null:
return whoAreYou();case ClientStatusMessageData() when clientStatus != null:
return clientStatus(_that.isPending);case ChannelStatusMessageData() when channelStatus != null:
return channelStatus(_that.watcherIds,_that.readyIds,_that.position,_that.playStatus);case PlayMessageData() when play != null:
return play();case PauseMessageData() when pause != null:
return pause(_that.position);case SeekMessageData() when seek != null:
return seek(_that.position);case PlayFinishedMessageData() when playFinished != null:
return playFinished();case ShareSubMessageData() when shareSub != null:
return shareSub(_that.url,_that.title);case CallMessageData() when call != null:
return call(_that.action);case TalkStatusMessageData() when talkStatus != null:
return talkStatus(_that.status);case PopmojiMessageData() when popmoji != null:
return popmoji(_that.popmojiCode);case DanmakuMessageData() when danmaku != null:
return danmaku(_that.message);case SparkMessageData() when spark != null:
return spark(_that.emoji,_that.fraction);case UnknownMessageData() when unknown != null:
return unknown();case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class WhatsOnMessageData implements MessageData {
  const WhatsOnMessageData({final  String? $type}): $type = $type ?? 'whats-on';
  factory WhatsOnMessageData.fromJson(Map<String, dynamic> json) => _$WhatsOnMessageDataFromJson(json);



@JsonKey(name: 'code')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$WhatsOnMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WhatsOnMessageData);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageData.whatsOn()';
}


}




/// @nodoc
@JsonSerializable()

class NowPlayingMessageData implements MessageData {
  const NowPlayingMessageData({required this.record, required this.sharer, final  String? $type}): $type = $type ?? 'now-playing';
  factory NowPlayingMessageData.fromJson(Map<String, dynamic> json) => _$NowPlayingMessageDataFromJson(json);

 final  VideoRecord record;
 final  User sharer;

@JsonKey(name: 'code')
final String $type;


/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NowPlayingMessageDataCopyWith<NowPlayingMessageData> get copyWith => _$NowPlayingMessageDataCopyWithImpl<NowPlayingMessageData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NowPlayingMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NowPlayingMessageData&&(identical(other.record, record) || other.record == record)&&(identical(other.sharer, sharer) || other.sharer == sharer));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,record,sharer);

@override
String toString() {
  return 'MessageData.nowPlaying(record: $record, sharer: $sharer)';
}


}

/// @nodoc
abstract mixin class $NowPlayingMessageDataCopyWith<$Res> implements $MessageDataCopyWith<$Res> {
  factory $NowPlayingMessageDataCopyWith(NowPlayingMessageData value, $Res Function(NowPlayingMessageData) _then) = _$NowPlayingMessageDataCopyWithImpl;
@useResult
$Res call({
 VideoRecord record, User sharer
});


$VideoRecordCopyWith<$Res> get record;

}
/// @nodoc
class _$NowPlayingMessageDataCopyWithImpl<$Res>
    implements $NowPlayingMessageDataCopyWith<$Res> {
  _$NowPlayingMessageDataCopyWithImpl(this._self, this._then);

  final NowPlayingMessageData _self;
  final $Res Function(NowPlayingMessageData) _then;

/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? record = null,Object? sharer = null,}) {
  return _then(NowPlayingMessageData(
record: null == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as VideoRecord,sharer: null == sharer ? _self.sharer : sharer // ignore: cast_nullable_to_non_nullable
as User,
  ));
}

/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoRecordCopyWith<$Res> get record {
  
  return $VideoRecordCopyWith<$Res>(_self.record, (value) {
    return _then(_self.copyWith(record: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class JoinInMessageData implements MessageData {
  const JoinInMessageData({required this.user, this.myShare, final  String? $type}): $type = $type ?? 'join-in';
  factory JoinInMessageData.fromJson(Map<String, dynamic> json) => _$JoinInMessageDataFromJson(json);

 final  User user;
 final  StartProjectionMessageData? myShare;

@JsonKey(name: 'code')
final String $type;


/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JoinInMessageDataCopyWith<JoinInMessageData> get copyWith => _$JoinInMessageDataCopyWithImpl<JoinInMessageData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$JoinInMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JoinInMessageData&&(identical(other.user, user) || other.user == user)&&const DeepCollectionEquality().equals(other.myShare, myShare));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,user,const DeepCollectionEquality().hash(myShare));

@override
String toString() {
  return 'MessageData.joinIn(user: $user, myShare: $myShare)';
}


}

/// @nodoc
abstract mixin class $JoinInMessageDataCopyWith<$Res> implements $MessageDataCopyWith<$Res> {
  factory $JoinInMessageDataCopyWith(JoinInMessageData value, $Res Function(JoinInMessageData) _then) = _$JoinInMessageDataCopyWithImpl;
@useResult
$Res call({
 User user, StartProjectionMessageData? myShare
});




}
/// @nodoc
class _$JoinInMessageDataCopyWithImpl<$Res>
    implements $JoinInMessageDataCopyWith<$Res> {
  _$JoinInMessageDataCopyWithImpl(this._self, this._then);

  final JoinInMessageData _self;
  final $Res Function(JoinInMessageData) _then;

/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? user = null,Object? myShare = freezed,}) {
  return _then(JoinInMessageData(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User,myShare: freezed == myShare ? _self.myShare : myShare // ignore: cast_nullable_to_non_nullable
as StartProjectionMessageData?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class HereAreMessageData implements MessageData {
  const HereAreMessageData({required final  List<User> watchers, required final  List<String> buffering, required final  List<String> talking, final  String? $type}): _watchers = watchers,_buffering = buffering,_talking = talking,$type = $type ?? 'here-are';
  factory HereAreMessageData.fromJson(Map<String, dynamic> json) => _$HereAreMessageDataFromJson(json);

 final  List<User> _watchers;
 List<User> get watchers {
  if (_watchers is EqualUnmodifiableListView) return _watchers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_watchers);
}

 final  List<String> _buffering;
 List<String> get buffering {
  if (_buffering is EqualUnmodifiableListView) return _buffering;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_buffering);
}

 final  List<String> _talking;
 List<String> get talking {
  if (_talking is EqualUnmodifiableListView) return _talking;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_talking);
}


@JsonKey(name: 'code')
final String $type;


/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HereAreMessageDataCopyWith<HereAreMessageData> get copyWith => _$HereAreMessageDataCopyWithImpl<HereAreMessageData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HereAreMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HereAreMessageData&&const DeepCollectionEquality().equals(other._watchers, _watchers)&&const DeepCollectionEquality().equals(other._buffering, _buffering)&&const DeepCollectionEquality().equals(other._talking, _talking));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_watchers),const DeepCollectionEquality().hash(_buffering),const DeepCollectionEquality().hash(_talking));

@override
String toString() {
  return 'MessageData.hereAre(watchers: $watchers, buffering: $buffering, talking: $talking)';
}


}

/// @nodoc
abstract mixin class $HereAreMessageDataCopyWith<$Res> implements $MessageDataCopyWith<$Res> {
  factory $HereAreMessageDataCopyWith(HereAreMessageData value, $Res Function(HereAreMessageData) _then) = _$HereAreMessageDataCopyWithImpl;
@useResult
$Res call({
 List<User> watchers, List<String> buffering, List<String> talking
});




}
/// @nodoc
class _$HereAreMessageDataCopyWithImpl<$Res>
    implements $HereAreMessageDataCopyWith<$Res> {
  _$HereAreMessageDataCopyWithImpl(this._self, this._then);

  final HereAreMessageData _self;
  final $Res Function(HereAreMessageData) _then;

/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? watchers = null,Object? buffering = null,Object? talking = null,}) {
  return _then(HereAreMessageData(
watchers: null == watchers ? _self._watchers : watchers // ignore: cast_nullable_to_non_nullable
as List<User>,buffering: null == buffering ? _self._buffering : buffering // ignore: cast_nullable_to_non_nullable
as List<String>,talking: null == talking ? _self._talking : talking // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc
@JsonSerializable()

class StartProjectionMessageData implements MessageData {
  const StartProjectionMessageData({required this.videoRecord, this.position = Duration.zero, final  String? $type}): $type = $type ?? 'start-projection';
  factory StartProjectionMessageData.fromJson(Map<String, dynamic> json) => _$StartProjectionMessageDataFromJson(json);

 final  VideoRecord videoRecord;
@JsonKey() final  Duration position;

@JsonKey(name: 'code')
final String $type;


/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StartProjectionMessageDataCopyWith<StartProjectionMessageData> get copyWith => _$StartProjectionMessageDataCopyWithImpl<StartProjectionMessageData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StartProjectionMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StartProjectionMessageData&&(identical(other.videoRecord, videoRecord) || other.videoRecord == videoRecord)&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,videoRecord,position);

@override
String toString() {
  return 'MessageData.startProjection(videoRecord: $videoRecord, position: $position)';
}


}

/// @nodoc
abstract mixin class $StartProjectionMessageDataCopyWith<$Res> implements $MessageDataCopyWith<$Res> {
  factory $StartProjectionMessageDataCopyWith(StartProjectionMessageData value, $Res Function(StartProjectionMessageData) _then) = _$StartProjectionMessageDataCopyWithImpl;
@useResult
$Res call({
 VideoRecord videoRecord, Duration position
});


$VideoRecordCopyWith<$Res> get videoRecord;

}
/// @nodoc
class _$StartProjectionMessageDataCopyWithImpl<$Res>
    implements $StartProjectionMessageDataCopyWith<$Res> {
  _$StartProjectionMessageDataCopyWithImpl(this._self, this._then);

  final StartProjectionMessageData _self;
  final $Res Function(StartProjectionMessageData) _then;

/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? videoRecord = null,Object? position = null,}) {
  return _then(StartProjectionMessageData(
videoRecord: null == videoRecord ? _self.videoRecord : videoRecord // ignore: cast_nullable_to_non_nullable
as VideoRecord,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}

/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoRecordCopyWith<$Res> get videoRecord {
  
  return $VideoRecordCopyWith<$Res>(_self.videoRecord, (value) {
    return _then(_self.copyWith(videoRecord: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class ResetMessageData implements MessageData {
  const ResetMessageData({final  String? $type}): $type = $type ?? 'reset';
  factory ResetMessageData.fromJson(Map<String, dynamic> json) => _$ResetMessageDataFromJson(json);



@JsonKey(name: 'code')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$ResetMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResetMessageData);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageData.reset()';
}


}




/// @nodoc
@JsonSerializable()

class AlohaMessageData implements MessageData {
  const AlohaMessageData({final  String? $type}): $type = $type ?? 'aloha';
  factory AlohaMessageData.fromJson(Map<String, dynamic> json) => _$AlohaMessageDataFromJson(json);



@JsonKey(name: 'code')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$AlohaMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlohaMessageData);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageData.aloha()';
}


}




/// @nodoc
@JsonSerializable()

class ByeMessageData implements MessageData {
  const ByeMessageData({final  String? $type}): $type = $type ?? 'bye';
  factory ByeMessageData.fromJson(Map<String, dynamic> json) => _$ByeMessageDataFromJson(json);



@JsonKey(name: 'code')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$ByeMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ByeMessageData);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageData.bye()';
}


}




/// @nodoc
@JsonSerializable()

class WhoAreYouMessageData implements MessageData {
  const WhoAreYouMessageData({final  String? $type}): $type = $type ?? 'who-are-you';
  factory WhoAreYouMessageData.fromJson(Map<String, dynamic> json) => _$WhoAreYouMessageDataFromJson(json);



@JsonKey(name: 'code')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$WhoAreYouMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WhoAreYouMessageData);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageData.whoAreYou()';
}


}




/// @nodoc
@JsonSerializable()

class ClientStatusMessageData implements MessageData {
  const ClientStatusMessageData({required this.isPending, final  String? $type}): $type = $type ?? 'client-status';
  factory ClientStatusMessageData.fromJson(Map<String, dynamic> json) => _$ClientStatusMessageDataFromJson(json);

 final  bool isPending;

@JsonKey(name: 'code')
final String $type;


/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClientStatusMessageDataCopyWith<ClientStatusMessageData> get copyWith => _$ClientStatusMessageDataCopyWithImpl<ClientStatusMessageData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClientStatusMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClientStatusMessageData&&(identical(other.isPending, isPending) || other.isPending == isPending));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isPending);

@override
String toString() {
  return 'MessageData.clientStatus(isPending: $isPending)';
}


}

/// @nodoc
abstract mixin class $ClientStatusMessageDataCopyWith<$Res> implements $MessageDataCopyWith<$Res> {
  factory $ClientStatusMessageDataCopyWith(ClientStatusMessageData value, $Res Function(ClientStatusMessageData) _then) = _$ClientStatusMessageDataCopyWithImpl;
@useResult
$Res call({
 bool isPending
});




}
/// @nodoc
class _$ClientStatusMessageDataCopyWithImpl<$Res>
    implements $ClientStatusMessageDataCopyWith<$Res> {
  _$ClientStatusMessageDataCopyWithImpl(this._self, this._then);

  final ClientStatusMessageData _self;
  final $Res Function(ClientStatusMessageData) _then;

/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? isPending = null,}) {
  return _then(ClientStatusMessageData(
isPending: null == isPending ? _self.isPending : isPending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class ChannelStatusMessageData implements MessageData {
  const ChannelStatusMessageData({required final  List<String> watcherIds, required final  List<String> readyIds, required this.position, required this.playStatus, final  String? $type}): _watcherIds = watcherIds,_readyIds = readyIds,$type = $type ?? 'channel-status';
  factory ChannelStatusMessageData.fromJson(Map<String, dynamic> json) => _$ChannelStatusMessageDataFromJson(json);

 final  List<String> _watcherIds;
 List<String> get watcherIds {
  if (_watcherIds is EqualUnmodifiableListView) return _watcherIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_watcherIds);
}

 final  List<String> _readyIds;
 List<String> get readyIds {
  if (_readyIds is EqualUnmodifiableListView) return _readyIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_readyIds);
}

 final  Duration position;
 final  ChannelPlayStatus playStatus;

@JsonKey(name: 'code')
final String $type;


/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChannelStatusMessageDataCopyWith<ChannelStatusMessageData> get copyWith => _$ChannelStatusMessageDataCopyWithImpl<ChannelStatusMessageData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChannelStatusMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChannelStatusMessageData&&const DeepCollectionEquality().equals(other._watcherIds, _watcherIds)&&const DeepCollectionEquality().equals(other._readyIds, _readyIds)&&(identical(other.position, position) || other.position == position)&&(identical(other.playStatus, playStatus) || other.playStatus == playStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_watcherIds),const DeepCollectionEquality().hash(_readyIds),position,playStatus);

@override
String toString() {
  return 'MessageData.channelStatus(watcherIds: $watcherIds, readyIds: $readyIds, position: $position, playStatus: $playStatus)';
}


}

/// @nodoc
abstract mixin class $ChannelStatusMessageDataCopyWith<$Res> implements $MessageDataCopyWith<$Res> {
  factory $ChannelStatusMessageDataCopyWith(ChannelStatusMessageData value, $Res Function(ChannelStatusMessageData) _then) = _$ChannelStatusMessageDataCopyWithImpl;
@useResult
$Res call({
 List<String> watcherIds, List<String> readyIds, Duration position, ChannelPlayStatus playStatus
});




}
/// @nodoc
class _$ChannelStatusMessageDataCopyWithImpl<$Res>
    implements $ChannelStatusMessageDataCopyWith<$Res> {
  _$ChannelStatusMessageDataCopyWithImpl(this._self, this._then);

  final ChannelStatusMessageData _self;
  final $Res Function(ChannelStatusMessageData) _then;

/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? watcherIds = null,Object? readyIds = null,Object? position = null,Object? playStatus = null,}) {
  return _then(ChannelStatusMessageData(
watcherIds: null == watcherIds ? _self._watcherIds : watcherIds // ignore: cast_nullable_to_non_nullable
as List<String>,readyIds: null == readyIds ? _self._readyIds : readyIds // ignore: cast_nullable_to_non_nullable
as List<String>,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,playStatus: null == playStatus ? _self.playStatus : playStatus // ignore: cast_nullable_to_non_nullable
as ChannelPlayStatus,
  ));
}


}

/// @nodoc
@JsonSerializable()

class PlayMessageData implements MessageData {
  const PlayMessageData({final  String? $type}): $type = $type ?? 'play';
  factory PlayMessageData.fromJson(Map<String, dynamic> json) => _$PlayMessageDataFromJson(json);



@JsonKey(name: 'code')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$PlayMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayMessageData);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageData.play()';
}


}




/// @nodoc
@JsonSerializable()

class PauseMessageData implements MessageData {
  const PauseMessageData({required this.position, final  String? $type}): $type = $type ?? 'pause';
  factory PauseMessageData.fromJson(Map<String, dynamic> json) => _$PauseMessageDataFromJson(json);

 final  Duration position;

@JsonKey(name: 'code')
final String $type;


/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PauseMessageDataCopyWith<PauseMessageData> get copyWith => _$PauseMessageDataCopyWithImpl<PauseMessageData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PauseMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PauseMessageData&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,position);

@override
String toString() {
  return 'MessageData.pause(position: $position)';
}


}

/// @nodoc
abstract mixin class $PauseMessageDataCopyWith<$Res> implements $MessageDataCopyWith<$Res> {
  factory $PauseMessageDataCopyWith(PauseMessageData value, $Res Function(PauseMessageData) _then) = _$PauseMessageDataCopyWithImpl;
@useResult
$Res call({
 Duration position
});




}
/// @nodoc
class _$PauseMessageDataCopyWithImpl<$Res>
    implements $PauseMessageDataCopyWith<$Res> {
  _$PauseMessageDataCopyWithImpl(this._self, this._then);

  final PauseMessageData _self;
  final $Res Function(PauseMessageData) _then;

/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? position = null,}) {
  return _then(PauseMessageData(
position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

/// @nodoc
@JsonSerializable()

class SeekMessageData implements MessageData {
  const SeekMessageData({required this.position, final  String? $type}): $type = $type ?? 'seek';
  factory SeekMessageData.fromJson(Map<String, dynamic> json) => _$SeekMessageDataFromJson(json);

 final  Duration position;

@JsonKey(name: 'code')
final String $type;


/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeekMessageDataCopyWith<SeekMessageData> get copyWith => _$SeekMessageDataCopyWithImpl<SeekMessageData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeekMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SeekMessageData&&(identical(other.position, position) || other.position == position));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,position);

@override
String toString() {
  return 'MessageData.seek(position: $position)';
}


}

/// @nodoc
abstract mixin class $SeekMessageDataCopyWith<$Res> implements $MessageDataCopyWith<$Res> {
  factory $SeekMessageDataCopyWith(SeekMessageData value, $Res Function(SeekMessageData) _then) = _$SeekMessageDataCopyWithImpl;
@useResult
$Res call({
 Duration position
});




}
/// @nodoc
class _$SeekMessageDataCopyWithImpl<$Res>
    implements $SeekMessageDataCopyWith<$Res> {
  _$SeekMessageDataCopyWithImpl(this._self, this._then);

  final SeekMessageData _self;
  final $Res Function(SeekMessageData) _then;

/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? position = null,}) {
  return _then(SeekMessageData(
position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

/// @nodoc
@JsonSerializable()

class PlayFinishedMessageData implements MessageData {
  const PlayFinishedMessageData({final  String? $type}): $type = $type ?? 'play-finished';
  factory PlayFinishedMessageData.fromJson(Map<String, dynamic> json) => _$PlayFinishedMessageDataFromJson(json);



@JsonKey(name: 'code')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$PlayFinishedMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayFinishedMessageData);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageData.playFinished()';
}


}




/// @nodoc
@JsonSerializable()

class ShareSubMessageData implements MessageData {
  const ShareSubMessageData({required this.url, required this.title, final  String? $type}): $type = $type ?? 'share-sub';
  factory ShareSubMessageData.fromJson(Map<String, dynamic> json) => _$ShareSubMessageDataFromJson(json);

 final  String url;
 final  String title;

@JsonKey(name: 'code')
final String $type;


/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShareSubMessageDataCopyWith<ShareSubMessageData> get copyWith => _$ShareSubMessageDataCopyWithImpl<ShareSubMessageData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShareSubMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShareSubMessageData&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,title);

@override
String toString() {
  return 'MessageData.shareSub(url: $url, title: $title)';
}


}

/// @nodoc
abstract mixin class $ShareSubMessageDataCopyWith<$Res> implements $MessageDataCopyWith<$Res> {
  factory $ShareSubMessageDataCopyWith(ShareSubMessageData value, $Res Function(ShareSubMessageData) _then) = _$ShareSubMessageDataCopyWithImpl;
@useResult
$Res call({
 String url, String title
});




}
/// @nodoc
class _$ShareSubMessageDataCopyWithImpl<$Res>
    implements $ShareSubMessageDataCopyWith<$Res> {
  _$ShareSubMessageDataCopyWithImpl(this._self, this._then);

  final ShareSubMessageData _self;
  final $Res Function(ShareSubMessageData) _then;

/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? url = null,Object? title = null,}) {
  return _then(ShareSubMessageData(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class CallMessageData implements MessageData {
  const CallMessageData({required this.action, final  String? $type}): $type = $type ?? 'call';
  factory CallMessageData.fromJson(Map<String, dynamic> json) => _$CallMessageDataFromJson(json);

 final  CallAction action;

@JsonKey(name: 'code')
final String $type;


/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CallMessageDataCopyWith<CallMessageData> get copyWith => _$CallMessageDataCopyWithImpl<CallMessageData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CallMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CallMessageData&&(identical(other.action, action) || other.action == action));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,action);

@override
String toString() {
  return 'MessageData.call(action: $action)';
}


}

/// @nodoc
abstract mixin class $CallMessageDataCopyWith<$Res> implements $MessageDataCopyWith<$Res> {
  factory $CallMessageDataCopyWith(CallMessageData value, $Res Function(CallMessageData) _then) = _$CallMessageDataCopyWithImpl;
@useResult
$Res call({
 CallAction action
});




}
/// @nodoc
class _$CallMessageDataCopyWithImpl<$Res>
    implements $CallMessageDataCopyWith<$Res> {
  _$CallMessageDataCopyWithImpl(this._self, this._then);

  final CallMessageData _self;
  final $Res Function(CallMessageData) _then;

/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? action = null,}) {
  return _then(CallMessageData(
action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as CallAction,
  ));
}


}

/// @nodoc
@JsonSerializable()

class TalkStatusMessageData implements MessageData {
  const TalkStatusMessageData({required this.status, final  String? $type}): $type = $type ?? 'talk-status';
  factory TalkStatusMessageData.fromJson(Map<String, dynamic> json) => _$TalkStatusMessageDataFromJson(json);

 final  TalkStatus status;

@JsonKey(name: 'code')
final String $type;


/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TalkStatusMessageDataCopyWith<TalkStatusMessageData> get copyWith => _$TalkStatusMessageDataCopyWithImpl<TalkStatusMessageData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TalkStatusMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TalkStatusMessageData&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status);

@override
String toString() {
  return 'MessageData.talkStatus(status: $status)';
}


}

/// @nodoc
abstract mixin class $TalkStatusMessageDataCopyWith<$Res> implements $MessageDataCopyWith<$Res> {
  factory $TalkStatusMessageDataCopyWith(TalkStatusMessageData value, $Res Function(TalkStatusMessageData) _then) = _$TalkStatusMessageDataCopyWithImpl;
@useResult
$Res call({
 TalkStatus status
});




}
/// @nodoc
class _$TalkStatusMessageDataCopyWithImpl<$Res>
    implements $TalkStatusMessageDataCopyWith<$Res> {
  _$TalkStatusMessageDataCopyWithImpl(this._self, this._then);

  final TalkStatusMessageData _self;
  final $Res Function(TalkStatusMessageData) _then;

/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? status = null,}) {
  return _then(TalkStatusMessageData(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TalkStatus,
  ));
}


}

/// @nodoc
@JsonSerializable()

class PopmojiMessageData implements MessageData {
  const PopmojiMessageData({required this.popmojiCode, final  String? $type}): $type = $type ?? 'popmoji';
  factory PopmojiMessageData.fromJson(Map<String, dynamic> json) => _$PopmojiMessageDataFromJson(json);

 final  String popmojiCode;

@JsonKey(name: 'code')
final String $type;


/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PopmojiMessageDataCopyWith<PopmojiMessageData> get copyWith => _$PopmojiMessageDataCopyWithImpl<PopmojiMessageData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PopmojiMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PopmojiMessageData&&(identical(other.popmojiCode, popmojiCode) || other.popmojiCode == popmojiCode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,popmojiCode);

@override
String toString() {
  return 'MessageData.popmoji(popmojiCode: $popmojiCode)';
}


}

/// @nodoc
abstract mixin class $PopmojiMessageDataCopyWith<$Res> implements $MessageDataCopyWith<$Res> {
  factory $PopmojiMessageDataCopyWith(PopmojiMessageData value, $Res Function(PopmojiMessageData) _then) = _$PopmojiMessageDataCopyWithImpl;
@useResult
$Res call({
 String popmojiCode
});




}
/// @nodoc
class _$PopmojiMessageDataCopyWithImpl<$Res>
    implements $PopmojiMessageDataCopyWith<$Res> {
  _$PopmojiMessageDataCopyWithImpl(this._self, this._then);

  final PopmojiMessageData _self;
  final $Res Function(PopmojiMessageData) _then;

/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? popmojiCode = null,}) {
  return _then(PopmojiMessageData(
popmojiCode: null == popmojiCode ? _self.popmojiCode : popmojiCode // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class DanmakuMessageData implements MessageData {
  const DanmakuMessageData({required this.message, final  String? $type}): $type = $type ?? 'danmaku';
  factory DanmakuMessageData.fromJson(Map<String, dynamic> json) => _$DanmakuMessageDataFromJson(json);

 final  String message;

@JsonKey(name: 'code')
final String $type;


/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DanmakuMessageDataCopyWith<DanmakuMessageData> get copyWith => _$DanmakuMessageDataCopyWithImpl<DanmakuMessageData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DanmakuMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DanmakuMessageData&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'MessageData.danmaku(message: $message)';
}


}

/// @nodoc
abstract mixin class $DanmakuMessageDataCopyWith<$Res> implements $MessageDataCopyWith<$Res> {
  factory $DanmakuMessageDataCopyWith(DanmakuMessageData value, $Res Function(DanmakuMessageData) _then) = _$DanmakuMessageDataCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$DanmakuMessageDataCopyWithImpl<$Res>
    implements $DanmakuMessageDataCopyWith<$Res> {
  _$DanmakuMessageDataCopyWithImpl(this._self, this._then);

  final DanmakuMessageData _self;
  final $Res Function(DanmakuMessageData) _then;

/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(DanmakuMessageData(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class SparkMessageData implements MessageData {
  const SparkMessageData({required this.emoji, @JsonKey(fromJson: _fractionalOffsetFromJson, toJson: _fractionalOffsetToJson) required this.fraction, final  String? $type}): $type = $type ?? 'spark';
  factory SparkMessageData.fromJson(Map<String, dynamic> json) => _$SparkMessageDataFromJson(json);

 final  String emoji;
@JsonKey(fromJson: _fractionalOffsetFromJson, toJson: _fractionalOffsetToJson) final  FractionalOffset fraction;

@JsonKey(name: 'code')
final String $type;


/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SparkMessageDataCopyWith<SparkMessageData> get copyWith => _$SparkMessageDataCopyWithImpl<SparkMessageData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SparkMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SparkMessageData&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.fraction, fraction) || other.fraction == fraction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,emoji,fraction);

@override
String toString() {
  return 'MessageData.spark(emoji: $emoji, fraction: $fraction)';
}


}

/// @nodoc
abstract mixin class $SparkMessageDataCopyWith<$Res> implements $MessageDataCopyWith<$Res> {
  factory $SparkMessageDataCopyWith(SparkMessageData value, $Res Function(SparkMessageData) _then) = _$SparkMessageDataCopyWithImpl;
@useResult
$Res call({
 String emoji,@JsonKey(fromJson: _fractionalOffsetFromJson, toJson: _fractionalOffsetToJson) FractionalOffset fraction
});




}
/// @nodoc
class _$SparkMessageDataCopyWithImpl<$Res>
    implements $SparkMessageDataCopyWith<$Res> {
  _$SparkMessageDataCopyWithImpl(this._self, this._then);

  final SparkMessageData _self;
  final $Res Function(SparkMessageData) _then;

/// Create a copy of MessageData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? emoji = null,Object? fraction = null,}) {
  return _then(SparkMessageData(
emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,fraction: null == fraction ? _self.fraction : fraction // ignore: cast_nullable_to_non_nullable
as FractionalOffset,
  ));
}


}

/// @nodoc
@JsonSerializable()

class UnknownMessageData implements MessageData {
  const UnknownMessageData({final  String? $type}): $type = $type ?? 'unknown';
  factory UnknownMessageData.fromJson(Map<String, dynamic> json) => _$UnknownMessageDataFromJson(json);



@JsonKey(name: 'code')
final String $type;



@override
Map<String, dynamic> toJson() {
  return _$UnknownMessageDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnknownMessageData);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageData.unknown()';
}


}




// dart format on
