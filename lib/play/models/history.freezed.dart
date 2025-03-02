// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WatchProgress _$WatchProgressFromJson(Map<String, dynamic> json) {
  return _WatchProgress.fromJson(json);
}

/// @nodoc
mixin _$WatchProgress {
  Duration get position => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;

  /// Serializes this WatchProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WatchProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WatchProgressCopyWith<WatchProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WatchProgressCopyWith<$Res> {
  factory $WatchProgressCopyWith(
          WatchProgress value, $Res Function(WatchProgress) then) =
      _$WatchProgressCopyWithImpl<$Res, WatchProgress>;
  @useResult
  $Res call({Duration position, Duration duration});
}

/// @nodoc
class _$WatchProgressCopyWithImpl<$Res, $Val extends WatchProgress>
    implements $WatchProgressCopyWith<$Res> {
  _$WatchProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WatchProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? duration = null,
  }) {
    return _then(_value.copyWith(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WatchProgressImplCopyWith<$Res>
    implements $WatchProgressCopyWith<$Res> {
  factory _$$WatchProgressImplCopyWith(
          _$WatchProgressImpl value, $Res Function(_$WatchProgressImpl) then) =
      __$$WatchProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Duration position, Duration duration});
}

/// @nodoc
class __$$WatchProgressImplCopyWithImpl<$Res>
    extends _$WatchProgressCopyWithImpl<$Res, _$WatchProgressImpl>
    implements _$$WatchProgressImplCopyWith<$Res> {
  __$$WatchProgressImplCopyWithImpl(
      _$WatchProgressImpl _value, $Res Function(_$WatchProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of WatchProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? duration = null,
  }) {
    return _then(_$WatchProgressImpl(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WatchProgressImpl extends _WatchProgress {
  const _$WatchProgressImpl({required this.position, required this.duration})
      : super._();

  factory _$WatchProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$WatchProgressImplFromJson(json);

  @override
  final Duration position;
  @override
  final Duration duration;

  @override
  String toString() {
    return 'WatchProgress(position: $position, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WatchProgressImpl &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, position, duration);

  /// Create a copy of WatchProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WatchProgressImplCopyWith<_$WatchProgressImpl> get copyWith =>
      __$$WatchProgressImplCopyWithImpl<_$WatchProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WatchProgressImplToJson(
      this,
    );
  }
}

abstract class _WatchProgress extends WatchProgress {
  const factory _WatchProgress(
      {required final Duration position,
      required final Duration duration}) = _$WatchProgressImpl;
  const _WatchProgress._() : super._();

  factory _WatchProgress.fromJson(Map<String, dynamic> json) =
      _$WatchProgressImpl.fromJson;

  @override
  Duration get position;
  @override
  Duration get duration;

  /// Create a copy of WatchProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WatchProgressImplCopyWith<_$WatchProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VideoSession _$VideoSessionFromJson(Map<String, dynamic> json) {
  return _VideoSession.fromJson(json);
}

/// @nodoc
mixin _$VideoSession {
  DateTime get updatedAt => throw _privateConstructorUsedError;
  VideoRecord get videoRecord => throw _privateConstructorUsedError;
  WatchProgress get progress => throw _privateConstructorUsedError;
  String? get subtitleUri => throw _privateConstructorUsedError;

  /// Serializes this VideoSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoSessionCopyWith<VideoSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoSessionCopyWith<$Res> {
  factory $VideoSessionCopyWith(
          VideoSession value, $Res Function(VideoSession) then) =
      _$VideoSessionCopyWithImpl<$Res, VideoSession>;
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
class _$VideoSessionCopyWithImpl<$Res, $Val extends VideoSession>
    implements $VideoSessionCopyWith<$Res> {
  _$VideoSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      videoRecord: null == videoRecord
          ? _value.videoRecord
          : videoRecord // ignore: cast_nullable_to_non_nullable
              as VideoRecord,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as WatchProgress,
      subtitleUri: freezed == subtitleUri
          ? _value.subtitleUri
          : subtitleUri // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of VideoSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VideoRecordCopyWith<$Res> get videoRecord {
    return $VideoRecordCopyWith<$Res>(_value.videoRecord, (value) {
      return _then(_value.copyWith(videoRecord: value) as $Val);
    });
  }

  /// Create a copy of VideoSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WatchProgressCopyWith<$Res> get progress {
    return $WatchProgressCopyWith<$Res>(_value.progress, (value) {
      return _then(_value.copyWith(progress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$VideoSessionImplCopyWith<$Res>
    implements $VideoSessionCopyWith<$Res> {
  factory _$$VideoSessionImplCopyWith(
          _$VideoSessionImpl value, $Res Function(_$VideoSessionImpl) then) =
      __$$VideoSessionImplCopyWithImpl<$Res>;
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
class __$$VideoSessionImplCopyWithImpl<$Res>
    extends _$VideoSessionCopyWithImpl<$Res, _$VideoSessionImpl>
    implements _$$VideoSessionImplCopyWith<$Res> {
  __$$VideoSessionImplCopyWithImpl(
      _$VideoSessionImpl _value, $Res Function(_$VideoSessionImpl) _then)
      : super(_value, _then);

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
    return _then(_$VideoSessionImpl(
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      videoRecord: null == videoRecord
          ? _value.videoRecord
          : videoRecord // ignore: cast_nullable_to_non_nullable
              as VideoRecord,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as WatchProgress,
      subtitleUri: freezed == subtitleUri
          ? _value.subtitleUri
          : subtitleUri // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoSessionImpl implements _VideoSession {
  const _$VideoSessionImpl(
      {required this.updatedAt,
      required this.videoRecord,
      required this.progress,
      this.subtitleUri});

  factory _$VideoSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoSessionImplFromJson(json);

  @override
  final DateTime updatedAt;
  @override
  final VideoRecord videoRecord;
  @override
  final WatchProgress progress;
  @override
  final String? subtitleUri;

  @override
  String toString() {
    return 'VideoSession(updatedAt: $updatedAt, videoRecord: $videoRecord, progress: $progress, subtitleUri: $subtitleUri)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoSessionImpl &&
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

  /// Create a copy of VideoSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoSessionImplCopyWith<_$VideoSessionImpl> get copyWith =>
      __$$VideoSessionImplCopyWithImpl<_$VideoSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoSessionImplToJson(
      this,
    );
  }
}

abstract class _VideoSession implements VideoSession {
  const factory _VideoSession(
      {required final DateTime updatedAt,
      required final VideoRecord videoRecord,
      required final WatchProgress progress,
      final String? subtitleUri}) = _$VideoSessionImpl;

  factory _VideoSession.fromJson(Map<String, dynamic> json) =
      _$VideoSessionImpl.fromJson;

  @override
  DateTime get updatedAt;
  @override
  VideoRecord get videoRecord;
  @override
  WatchProgress get progress;
  @override
  String? get subtitleUri;

  /// Create a copy of VideoSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoSessionImplCopyWith<_$VideoSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

History _$HistoryFromJson(Map<String, dynamic> json) {
  return _History.fromJson(json);
}

/// @nodoc
mixin _$History {
  Map<String, VideoSession> get value => throw _privateConstructorUsedError;

  /// Serializes this History to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of History
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HistoryCopyWith<History> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HistoryCopyWith<$Res> {
  factory $HistoryCopyWith(History value, $Res Function(History) then) =
      _$HistoryCopyWithImpl<$Res, History>;
  @useResult
  $Res call({Map<String, VideoSession> value});
}

/// @nodoc
class _$HistoryCopyWithImpl<$Res, $Val extends History>
    implements $HistoryCopyWith<$Res> {
  _$HistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of History
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as Map<String, VideoSession>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HistoryImplCopyWith<$Res> implements $HistoryCopyWith<$Res> {
  factory _$$HistoryImplCopyWith(
          _$HistoryImpl value, $Res Function(_$HistoryImpl) then) =
      __$$HistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, VideoSession> value});
}

/// @nodoc
class __$$HistoryImplCopyWithImpl<$Res>
    extends _$HistoryCopyWithImpl<$Res, _$HistoryImpl>
    implements _$$HistoryImplCopyWith<$Res> {
  __$$HistoryImplCopyWithImpl(
      _$HistoryImpl _value, $Res Function(_$HistoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of History
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_$HistoryImpl(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as Map<String, VideoSession>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HistoryImpl extends _History {
  const _$HistoryImpl({required this.value}) : super._();

  factory _$HistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$HistoryImplFromJson(json);

  @override
  final Map<String, VideoSession> value;

  @override
  String toString() {
    return 'History(value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HistoryImpl &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(value));

  /// Create a copy of History
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HistoryImplCopyWith<_$HistoryImpl> get copyWith =>
      __$$HistoryImplCopyWithImpl<_$HistoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HistoryImplToJson(
      this,
    );
  }
}

abstract class _History extends History {
  const factory _History({required final Map<String, VideoSession> value}) =
      _$HistoryImpl;
  const _History._() : super._();

  factory _History.fromJson(Map<String, dynamic> json) = _$HistoryImpl.fromJson;

  @override
  Map<String, VideoSession> get value;

  /// Create a copy of History
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HistoryImplCopyWith<_$HistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
