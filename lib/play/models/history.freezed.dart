// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WatchProgress {
  Duration get position;
  Duration get duration;

  /// Create a copy of WatchProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WatchProgressCopyWith<WatchProgress> get copyWith =>
      _$WatchProgressCopyWithImpl<WatchProgress>(
          this as WatchProgress, _$identity);

  /// Serializes this WatchProgress to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WatchProgress &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, position, duration);

  @override
  String toString() {
    return 'WatchProgress(position: $position, duration: $duration)';
  }
}

/// @nodoc
abstract mixin class $WatchProgressCopyWith<$Res> {
  factory $WatchProgressCopyWith(
          WatchProgress value, $Res Function(WatchProgress) _then) =
      _$WatchProgressCopyWithImpl;
  @useResult
  $Res call({Duration position, Duration duration});
}

/// @nodoc
class _$WatchProgressCopyWithImpl<$Res>
    implements $WatchProgressCopyWith<$Res> {
  _$WatchProgressCopyWithImpl(this._self, this._then);

  final WatchProgress _self;
  final $Res Function(WatchProgress) _then;

  /// Create a copy of WatchProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? duration = null,
  }) {
    return _then(_self.copyWith(
      position: null == position
          ? _self.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      duration: null == duration
          ? _self.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _WatchProgress extends WatchProgress {
  const _WatchProgress({required this.position, required this.duration})
      : super._();
  factory _WatchProgress.fromJson(Map<String, dynamic> json) =>
      _$WatchProgressFromJson(json);

  @override
  final Duration position;
  @override
  final Duration duration;

  /// Create a copy of WatchProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WatchProgressCopyWith<_WatchProgress> get copyWith =>
      __$WatchProgressCopyWithImpl<_WatchProgress>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WatchProgressToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WatchProgress &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, position, duration);

  @override
  String toString() {
    return 'WatchProgress(position: $position, duration: $duration)';
  }
}

/// @nodoc
abstract mixin class _$WatchProgressCopyWith<$Res>
    implements $WatchProgressCopyWith<$Res> {
  factory _$WatchProgressCopyWith(
          _WatchProgress value, $Res Function(_WatchProgress) _then) =
      __$WatchProgressCopyWithImpl;
  @override
  @useResult
  $Res call({Duration position, Duration duration});
}

/// @nodoc
class __$WatchProgressCopyWithImpl<$Res>
    implements _$WatchProgressCopyWith<$Res> {
  __$WatchProgressCopyWithImpl(this._self, this._then);

  final _WatchProgress _self;
  final $Res Function(_WatchProgress) _then;

  /// Create a copy of WatchProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? position = null,
    Object? duration = null,
  }) {
    return _then(_WatchProgress(
      position: null == position
          ? _self.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      duration: null == duration
          ? _self.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc
mixin _$VideoSession {
  DateTime get updatedAt;
  VideoRecord get videoRecord;
  WatchProgress get progress;
  String? get subtitleUri;

  /// Create a copy of VideoSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VideoSessionCopyWith<VideoSession> get copyWith =>
      _$VideoSessionCopyWithImpl<VideoSession>(
          this as VideoSession, _$identity);

  /// Serializes this VideoSession to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VideoSession &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.videoRecord, videoRecord) ||
                other.videoRecord == videoRecord) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.subtitleUri, subtitleUri) ||
                other.subtitleUri == subtitleUri));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, updatedAt, videoRecord, progress, subtitleUri);

  @override
  String toString() {
    return 'VideoSession(updatedAt: $updatedAt, videoRecord: $videoRecord, progress: $progress, subtitleUri: $subtitleUri)';
  }
}

/// @nodoc
abstract mixin class $VideoSessionCopyWith<$Res> {
  factory $VideoSessionCopyWith(
          VideoSession value, $Res Function(VideoSession) _then) =
      _$VideoSessionCopyWithImpl;
  @useResult
  $Res call(
      {DateTime updatedAt,
      VideoRecord videoRecord,
      WatchProgress progress,
      String? subtitleUri});

  $VideoRecordCopyWith<$Res> get videoRecord;
  $WatchProgressCopyWith<$Res> get progress;
}

/// @nodoc
class _$VideoSessionCopyWithImpl<$Res> implements $VideoSessionCopyWith<$Res> {
  _$VideoSessionCopyWithImpl(this._self, this._then);

  final VideoSession _self;
  final $Res Function(VideoSession) _then;

  /// Create a copy of VideoSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? updatedAt = null,
    Object? videoRecord = null,
    Object? progress = null,
    Object? subtitleUri = freezed,
  }) {
    return _then(_self.copyWith(
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      videoRecord: null == videoRecord
          ? _self.videoRecord
          : videoRecord // ignore: cast_nullable_to_non_nullable
              as VideoRecord,
      progress: null == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as WatchProgress,
      subtitleUri: freezed == subtitleUri
          ? _self.subtitleUri
          : subtitleUri // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of VideoSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VideoRecordCopyWith<$Res> get videoRecord {
    return $VideoRecordCopyWith<$Res>(_self.videoRecord, (value) {
      return _then(_self.copyWith(videoRecord: value));
    });
  }

  /// Create a copy of VideoSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WatchProgressCopyWith<$Res> get progress {
    return $WatchProgressCopyWith<$Res>(_self.progress, (value) {
      return _then(_self.copyWith(progress: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _VideoSession implements VideoSession {
  const _VideoSession(
      {required this.updatedAt,
      required this.videoRecord,
      required this.progress,
      this.subtitleUri});
  factory _VideoSession.fromJson(Map<String, dynamic> json) =>
      _$VideoSessionFromJson(json);

  @override
  final DateTime updatedAt;
  @override
  final VideoRecord videoRecord;
  @override
  final WatchProgress progress;
  @override
  final String? subtitleUri;

  /// Create a copy of VideoSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$VideoSessionCopyWith<_VideoSession> get copyWith =>
      __$VideoSessionCopyWithImpl<_VideoSession>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$VideoSessionToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _VideoSession &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.videoRecord, videoRecord) ||
                other.videoRecord == videoRecord) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.subtitleUri, subtitleUri) ||
                other.subtitleUri == subtitleUri));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, updatedAt, videoRecord, progress, subtitleUri);

  @override
  String toString() {
    return 'VideoSession(updatedAt: $updatedAt, videoRecord: $videoRecord, progress: $progress, subtitleUri: $subtitleUri)';
  }
}

/// @nodoc
abstract mixin class _$VideoSessionCopyWith<$Res>
    implements $VideoSessionCopyWith<$Res> {
  factory _$VideoSessionCopyWith(
          _VideoSession value, $Res Function(_VideoSession) _then) =
      __$VideoSessionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {DateTime updatedAt,
      VideoRecord videoRecord,
      WatchProgress progress,
      String? subtitleUri});

  @override
  $VideoRecordCopyWith<$Res> get videoRecord;
  @override
  $WatchProgressCopyWith<$Res> get progress;
}

/// @nodoc
class __$VideoSessionCopyWithImpl<$Res>
    implements _$VideoSessionCopyWith<$Res> {
  __$VideoSessionCopyWithImpl(this._self, this._then);

  final _VideoSession _self;
  final $Res Function(_VideoSession) _then;

  /// Create a copy of VideoSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? updatedAt = null,
    Object? videoRecord = null,
    Object? progress = null,
    Object? subtitleUri = freezed,
  }) {
    return _then(_VideoSession(
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      videoRecord: null == videoRecord
          ? _self.videoRecord
          : videoRecord // ignore: cast_nullable_to_non_nullable
              as VideoRecord,
      progress: null == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as WatchProgress,
      subtitleUri: freezed == subtitleUri
          ? _self.subtitleUri
          : subtitleUri // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of VideoSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VideoRecordCopyWith<$Res> get videoRecord {
    return $VideoRecordCopyWith<$Res>(_self.videoRecord, (value) {
      return _then(_self.copyWith(videoRecord: value));
    });
  }

  /// Create a copy of VideoSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WatchProgressCopyWith<$Res> get progress {
    return $WatchProgressCopyWith<$Res>(_self.progress, (value) {
      return _then(_self.copyWith(progress: value));
    });
  }
}

/// @nodoc
mixin _$History {
  Map<String, VideoSession> get value;

  /// Create a copy of History
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HistoryCopyWith<History> get copyWith =>
      _$HistoryCopyWithImpl<History>(this as History, _$identity);

  /// Serializes this History to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is History &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(value));

  @override
  String toString() {
    return 'History(value: $value)';
  }
}

/// @nodoc
abstract mixin class $HistoryCopyWith<$Res> {
  factory $HistoryCopyWith(History value, $Res Function(History) _then) =
      _$HistoryCopyWithImpl;
  @useResult
  $Res call({Map<String, VideoSession> value});
}

/// @nodoc
class _$HistoryCopyWithImpl<$Res> implements $HistoryCopyWith<$Res> {
  _$HistoryCopyWithImpl(this._self, this._then);

  final History _self;
  final $Res Function(History) _then;

  /// Create a copy of History
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_self.copyWith(
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as Map<String, VideoSession>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _History extends History {
  const _History({required this.value}) : super._();
  factory _History.fromJson(Map<String, dynamic> json) =>
      _$HistoryFromJson(json);

  @override
  final Map<String, VideoSession> value;

  /// Create a copy of History
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HistoryCopyWith<_History> get copyWith =>
      __$HistoryCopyWithImpl<_History>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$HistoryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _History &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(value));

  @override
  String toString() {
    return 'History(value: $value)';
  }
}

/// @nodoc
abstract mixin class _$HistoryCopyWith<$Res> implements $HistoryCopyWith<$Res> {
  factory _$HistoryCopyWith(_History value, $Res Function(_History) _then) =
      __$HistoryCopyWithImpl;
  @override
  @useResult
  $Res call({Map<String, VideoSession> value});
}

/// @nodoc
class __$HistoryCopyWithImpl<$Res> implements _$HistoryCopyWith<$Res> {
  __$HistoryCopyWithImpl(this._self, this._then);

  final _History _self;
  final $Res Function(_History) _then;

  /// Create a copy of History
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? value = null,
  }) {
    return _then(_History(
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as Map<String, VideoSession>,
    ));
  }
}

// dart format on
