// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'play_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlayPayload {
  VideoRecord get record;
  VideoSources get sources;
  int get videoSourceIndex;

  /// Create a copy of PlayPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PlayPayloadCopyWith<PlayPayload> get copyWith =>
      _$PlayPayloadCopyWithImpl<PlayPayload>(this as PlayPayload, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PlayPayload &&
            (identical(other.record, record) || other.record == record) &&
            (identical(other.sources, sources) || other.sources == sources) &&
            (identical(other.videoSourceIndex, videoSourceIndex) ||
                other.videoSourceIndex == videoSourceIndex));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, record, sources, videoSourceIndex);

  @override
  String toString() {
    return 'PlayPayload(record: $record, sources: $sources, videoSourceIndex: $videoSourceIndex)';
  }
}

/// @nodoc
abstract mixin class $PlayPayloadCopyWith<$Res> {
  factory $PlayPayloadCopyWith(
          PlayPayload value, $Res Function(PlayPayload) _then) =
      _$PlayPayloadCopyWithImpl;
  @useResult
  $Res call({VideoRecord record, VideoSources sources, int videoSourceIndex});

  $VideoRecordCopyWith<$Res> get record;
}

/// @nodoc
class _$PlayPayloadCopyWithImpl<$Res> implements $PlayPayloadCopyWith<$Res> {
  _$PlayPayloadCopyWithImpl(this._self, this._then);

  final PlayPayload _self;
  final $Res Function(PlayPayload) _then;

  /// Create a copy of PlayPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? record = null,
    Object? sources = null,
    Object? videoSourceIndex = null,
  }) {
    return _then(_self.copyWith(
      record: null == record
          ? _self.record
          : record // ignore: cast_nullable_to_non_nullable
              as VideoRecord,
      sources: null == sources
          ? _self.sources
          : sources // ignore: cast_nullable_to_non_nullable
              as VideoSources,
      videoSourceIndex: null == videoSourceIndex
          ? _self.videoSourceIndex
          : videoSourceIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of PlayPayload
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

class _PlayPayload implements PlayPayload {
  _PlayPayload(
      {required this.record, required this.sources, this.videoSourceIndex = 0});

  @override
  final VideoRecord record;
  @override
  final VideoSources sources;
  @override
  @JsonKey()
  final int videoSourceIndex;

  /// Create a copy of PlayPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PlayPayloadCopyWith<_PlayPayload> get copyWith =>
      __$PlayPayloadCopyWithImpl<_PlayPayload>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PlayPayload &&
            (identical(other.record, record) || other.record == record) &&
            (identical(other.sources, sources) || other.sources == sources) &&
            (identical(other.videoSourceIndex, videoSourceIndex) ||
                other.videoSourceIndex == videoSourceIndex));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, record, sources, videoSourceIndex);

  @override
  String toString() {
    return 'PlayPayload(record: $record, sources: $sources, videoSourceIndex: $videoSourceIndex)';
  }
}

/// @nodoc
abstract mixin class _$PlayPayloadCopyWith<$Res>
    implements $PlayPayloadCopyWith<$Res> {
  factory _$PlayPayloadCopyWith(
          _PlayPayload value, $Res Function(_PlayPayload) _then) =
      __$PlayPayloadCopyWithImpl;
  @override
  @useResult
  $Res call({VideoRecord record, VideoSources sources, int videoSourceIndex});

  @override
  $VideoRecordCopyWith<$Res> get record;
}

/// @nodoc
class __$PlayPayloadCopyWithImpl<$Res> implements _$PlayPayloadCopyWith<$Res> {
  __$PlayPayloadCopyWithImpl(this._self, this._then);

  final _PlayPayload _self;
  final $Res Function(_PlayPayload) _then;

  /// Create a copy of PlayPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? record = null,
    Object? sources = null,
    Object? videoSourceIndex = null,
  }) {
    return _then(_PlayPayload(
      record: null == record
          ? _self.record
          : record // ignore: cast_nullable_to_non_nullable
              as VideoRecord,
      sources: null == sources
          ? _self.sources
          : sources // ignore: cast_nullable_to_non_nullable
              as VideoSources,
      videoSourceIndex: null == videoSourceIndex
          ? _self.videoSourceIndex
          : videoSourceIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  /// Create a copy of PlayPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VideoRecordCopyWith<$Res> get record {
    return $VideoRecordCopyWith<$Res>(_self.record, (value) {
      return _then(_self.copyWith(record: value));
    });
  }
}

// dart format on
