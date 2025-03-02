// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VideoRecord _$VideoRecordFromJson(Map<String, dynamic> json) {
  return _VideoRecord.fromJson(json);
}

/// @nodoc
mixin _$VideoRecord {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get thumbUrl => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;

  /// Serializes this VideoRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoRecordCopyWith<VideoRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoRecordCopyWith<$Res> {
  factory $VideoRecordCopyWith(
          VideoRecord value, $Res Function(VideoRecord) then) =
      _$VideoRecordCopyWithImpl<$Res, VideoRecord>;
  @useResult
  $Res call(
      {String id, String title, String? thumbUrl, String source, String path});
}

/// @nodoc
class _$VideoRecordCopyWithImpl<$Res, $Val extends VideoRecord>
    implements $VideoRecordCopyWith<$Res> {
  _$VideoRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? thumbUrl = freezed,
    Object? source = null,
    Object? path = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      thumbUrl: freezed == thumbUrl
          ? _value.thumbUrl
          : thumbUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoRecordImplCopyWith<$Res>
    implements $VideoRecordCopyWith<$Res> {
  factory _$$VideoRecordImplCopyWith(
          _$VideoRecordImpl value, $Res Function(_$VideoRecordImpl) then) =
      __$$VideoRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, String title, String? thumbUrl, String source, String path});
}

/// @nodoc
class __$$VideoRecordImplCopyWithImpl<$Res>
    extends _$VideoRecordCopyWithImpl<$Res, _$VideoRecordImpl>
    implements _$$VideoRecordImplCopyWith<$Res> {
  __$$VideoRecordImplCopyWithImpl(
      _$VideoRecordImpl _value, $Res Function(_$VideoRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? thumbUrl = freezed,
    Object? source = null,
    Object? path = null,
  }) {
    return _then(_$VideoRecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      thumbUrl: freezed == thumbUrl
          ? _value.thumbUrl
          : thumbUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoRecordImpl implements _VideoRecord {
  const _$VideoRecordImpl(
      {required this.id,
      required this.title,
      this.thumbUrl,
      required this.source,
      required this.path});

  factory _$VideoRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoRecordImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? thumbUrl;
  @override
  final String source;
  @override
  final String path;

  @override
  String toString() {
    return 'VideoRecord(id: $id, title: $title, thumbUrl: $thumbUrl, source: $source, path: $path)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.thumbUrl, thumbUrl) ||
                other.thumbUrl == thumbUrl) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.path, path) || other.path == path));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, thumbUrl, source, path);

  /// Create a copy of VideoRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoRecordImplCopyWith<_$VideoRecordImpl> get copyWith =>
      __$$VideoRecordImplCopyWithImpl<_$VideoRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoRecordImplToJson(
      this,
    );
  }
}

abstract class _VideoRecord implements VideoRecord {
  const factory _VideoRecord(
      {required final String id,
      required final String title,
      final String? thumbUrl,
      required final String source,
      required final String path}) = _$VideoRecordImpl;

  factory _VideoRecord.fromJson(Map<String, dynamic> json) =
      _$VideoRecordImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get thumbUrl;
  @override
  String get source;
  @override
  String get path;

  /// Create a copy of VideoRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoRecordImplCopyWith<_$VideoRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
