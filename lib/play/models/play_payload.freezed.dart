// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'play_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PlayPayload {
  VideoRecord get record => throw _privateConstructorUsedError;
  VideoSources get sources => throw _privateConstructorUsedError;
  int get videoSourceIndex => throw _privateConstructorUsedError;

  /// Create a copy of PlayPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayPayloadCopyWith<PlayPayload> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayPayloadCopyWith<$Res> {
  factory $PlayPayloadCopyWith(
          PlayPayload value, $Res Function(PlayPayload) then) =
      _$PlayPayloadCopyWithImpl<$Res, PlayPayload>;
  @useResult
  $Res call({VideoRecord record, VideoSources sources, int videoSourceIndex});

  $VideoRecordCopyWith<$Res> get record;
}

/// @nodoc
class _$PlayPayloadCopyWithImpl<$Res, $Val extends PlayPayload>
    implements $PlayPayloadCopyWith<$Res> {
  _$PlayPayloadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? record = null,
    Object? sources = null,
    Object? videoSourceIndex = null,
  }) {
    return _then(_value.copyWith(
      record: null == record
          ? _value.record
          : record // ignore: cast_nullable_to_non_nullable
              as VideoRecord,
      sources: null == sources
          ? _value.sources
          : sources // ignore: cast_nullable_to_non_nullable
              as VideoSources,
      videoSourceIndex: null == videoSourceIndex
          ? _value.videoSourceIndex
          : videoSourceIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of PlayPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VideoRecordCopyWith<$Res> get record {
    return $VideoRecordCopyWith<$Res>(_value.record, (value) {
      return _then(_value.copyWith(record: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlayPayloadImplCopyWith<$Res>
    implements $PlayPayloadCopyWith<$Res> {
  factory _$$PlayPayloadImplCopyWith(
          _$PlayPayloadImpl value, $Res Function(_$PlayPayloadImpl) then) =
      __$$PlayPayloadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({VideoRecord record, VideoSources sources, int videoSourceIndex});

  @override
  $VideoRecordCopyWith<$Res> get record;
}

/// @nodoc
class __$$PlayPayloadImplCopyWithImpl<$Res>
    extends _$PlayPayloadCopyWithImpl<$Res, _$PlayPayloadImpl>
    implements _$$PlayPayloadImplCopyWith<$Res> {
  __$$PlayPayloadImplCopyWithImpl(
      _$PlayPayloadImpl _value, $Res Function(_$PlayPayloadImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlayPayload
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? record = null,
    Object? sources = null,
    Object? videoSourceIndex = null,
  }) {
    return _then(_$PlayPayloadImpl(
      record: null == record
          ? _value.record
          : record // ignore: cast_nullable_to_non_nullable
              as VideoRecord,
      sources: null == sources
          ? _value.sources
          : sources // ignore: cast_nullable_to_non_nullable
              as VideoSources,
      videoSourceIndex: null == videoSourceIndex
          ? _value.videoSourceIndex
          : videoSourceIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$PlayPayloadImpl implements _PlayPayload {
  _$PlayPayloadImpl(
      {required this.record, required this.sources, this.videoSourceIndex = 0});

  @override
  final VideoRecord record;
  @override
  final VideoSources sources;
  @override
  @JsonKey()
  final int videoSourceIndex;

  @override
  String toString() {
    return 'PlayPayload(record: $record, sources: $sources, videoSourceIndex: $videoSourceIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayPayloadImpl &&
            (identical(other.record, record) || other.record == record) &&
            (identical(other.sources, sources) || other.sources == sources) &&
            (identical(other.videoSourceIndex, videoSourceIndex) ||
                other.videoSourceIndex == videoSourceIndex));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, record, sources, videoSourceIndex);

  /// Create a copy of PlayPayload
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayPayloadImplCopyWith<_$PlayPayloadImpl> get copyWith =>
      __$$PlayPayloadImplCopyWithImpl<_$PlayPayloadImpl>(this, _$identity);
}

abstract class _PlayPayload implements PlayPayload {
  factory _PlayPayload(
      {required final VideoRecord record,
      required final VideoSources sources,
      final int videoSourceIndex}) = _$PlayPayloadImpl;

  @override
  VideoRecord get record;
  @override
  VideoSources get sources;
  @override
  int get videoSourceIndex;

  /// Create a copy of PlayPayload
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayPayloadImplCopyWith<_$PlayPayloadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
