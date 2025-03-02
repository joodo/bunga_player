// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AudioTrack {
  String get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;

  /// Create a copy of AudioTrack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AudioTrackCopyWith<AudioTrack> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioTrackCopyWith<$Res> {
  factory $AudioTrackCopyWith(
          AudioTrack value, $Res Function(AudioTrack) then) =
      _$AudioTrackCopyWithImpl<$Res, AudioTrack>;
  @useResult
  $Res call({String id, String? title, String? language});
}

/// @nodoc
class _$AudioTrackCopyWithImpl<$Res, $Val extends AudioTrack>
    implements $AudioTrackCopyWith<$Res> {
  _$AudioTrackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AudioTrack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? language = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AudioTrackImplCopyWith<$Res>
    implements $AudioTrackCopyWith<$Res> {
  factory _$$AudioTrackImplCopyWith(
          _$AudioTrackImpl value, $Res Function(_$AudioTrackImpl) then) =
      __$$AudioTrackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String? title, String? language});
}

/// @nodoc
class __$$AudioTrackImplCopyWithImpl<$Res>
    extends _$AudioTrackCopyWithImpl<$Res, _$AudioTrackImpl>
    implements _$$AudioTrackImplCopyWith<$Res> {
  __$$AudioTrackImplCopyWithImpl(
      _$AudioTrackImpl _value, $Res Function(_$AudioTrackImpl) _then)
      : super(_value, _then);

  /// Create a copy of AudioTrack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? language = freezed,
  }) {
    return _then(_$AudioTrackImpl(
      null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$AudioTrackImpl implements _AudioTrack {
  _$AudioTrackImpl(this.id, [this.title, this.language]);

  @override
  final String id;
  @override
  final String? title;
  @override
  final String? language;

  @override
  String toString() {
    return 'AudioTrack(id: $id, title: $title, language: $language)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioTrackImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, language);

  /// Create a copy of AudioTrack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioTrackImplCopyWith<_$AudioTrackImpl> get copyWith =>
      __$$AudioTrackImplCopyWithImpl<_$AudioTrackImpl>(this, _$identity);
}

abstract class _AudioTrack implements AudioTrack {
  factory _AudioTrack(final String id,
      [final String? title, final String? language]) = _$AudioTrackImpl;

  @override
  String get id;
  @override
  String? get title;
  @override
  String? get language;

  /// Create a copy of AudioTrack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AudioTrackImplCopyWith<_$AudioTrackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SubtitleTrack {
  String get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;
  String? get uri => throw _privateConstructorUsedError;

  /// Create a copy of SubtitleTrack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubtitleTrackCopyWith<SubtitleTrack> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubtitleTrackCopyWith<$Res> {
  factory $SubtitleTrackCopyWith(
          SubtitleTrack value, $Res Function(SubtitleTrack) then) =
      _$SubtitleTrackCopyWithImpl<$Res, SubtitleTrack>;
  @useResult
  $Res call({String id, String? title, String? language, String? uri});
}

/// @nodoc
class _$SubtitleTrackCopyWithImpl<$Res, $Val extends SubtitleTrack>
    implements $SubtitleTrackCopyWith<$Res> {
  _$SubtitleTrackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubtitleTrack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? language = freezed,
    Object? uri = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      uri: freezed == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubtitleTrackImplCopyWith<$Res>
    implements $SubtitleTrackCopyWith<$Res> {
  factory _$$SubtitleTrackImplCopyWith(
          _$SubtitleTrackImpl value, $Res Function(_$SubtitleTrackImpl) then) =
      __$$SubtitleTrackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String? title, String? language, String? uri});
}

/// @nodoc
class __$$SubtitleTrackImplCopyWithImpl<$Res>
    extends _$SubtitleTrackCopyWithImpl<$Res, _$SubtitleTrackImpl>
    implements _$$SubtitleTrackImplCopyWith<$Res> {
  __$$SubtitleTrackImplCopyWithImpl(
      _$SubtitleTrackImpl _value, $Res Function(_$SubtitleTrackImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubtitleTrack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? language = freezed,
    Object? uri = freezed,
  }) {
    return _then(_$SubtitleTrackImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      uri: freezed == uri
          ? _value.uri
          : uri // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SubtitleTrackImpl implements _SubtitleTrack {
  _$SubtitleTrackImpl({required this.id, this.title, this.language, this.uri});

  @override
  final String id;
  @override
  final String? title;
  @override
  final String? language;
  @override
  final String? uri;

  @override
  String toString() {
    return 'SubtitleTrack(id: $id, title: $title, language: $language, uri: $uri)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubtitleTrackImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.uri, uri) || other.uri == uri));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, language, uri);

  /// Create a copy of SubtitleTrack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubtitleTrackImplCopyWith<_$SubtitleTrackImpl> get copyWith =>
      __$$SubtitleTrackImplCopyWithImpl<_$SubtitleTrackImpl>(this, _$identity);
}

abstract class _SubtitleTrack implements SubtitleTrack {
  factory _SubtitleTrack(
      {required final String id,
      final String? title,
      final String? language,
      final String? uri}) = _$SubtitleTrackImpl;

  @override
  String get id;
  @override
  String? get title;
  @override
  String? get language;
  @override
  String? get uri;

  /// Create a copy of SubtitleTrack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubtitleTrackImplCopyWith<_$SubtitleTrackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
