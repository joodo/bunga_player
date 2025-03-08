// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AudioTrack {
  String get id;
  String? get title;
  String? get language;

  /// Create a copy of AudioTrack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AudioTrackCopyWith<AudioTrack> get copyWith =>
      _$AudioTrackCopyWithImpl<AudioTrack>(this as AudioTrack, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AudioTrack &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, language);

  @override
  String toString() {
    return 'AudioTrack(id: $id, title: $title, language: $language)';
  }
}

/// @nodoc
abstract mixin class $AudioTrackCopyWith<$Res> {
  factory $AudioTrackCopyWith(
          AudioTrack value, $Res Function(AudioTrack) _then) =
      _$AudioTrackCopyWithImpl;
  @useResult
  $Res call({String id, String? title, String? language});
}

/// @nodoc
class _$AudioTrackCopyWithImpl<$Res> implements $AudioTrackCopyWith<$Res> {
  _$AudioTrackCopyWithImpl(this._self, this._then);

  final AudioTrack _self;
  final $Res Function(AudioTrack) _then;

  /// Create a copy of AudioTrack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? language = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _AudioTrack implements AudioTrack {
  _AudioTrack(this.id, [this.title, this.language]);

  @override
  final String id;
  @override
  final String? title;
  @override
  final String? language;

  /// Create a copy of AudioTrack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AudioTrackCopyWith<_AudioTrack> get copyWith =>
      __$AudioTrackCopyWithImpl<_AudioTrack>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AudioTrack &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.language, language) ||
                other.language == language));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, language);

  @override
  String toString() {
    return 'AudioTrack(id: $id, title: $title, language: $language)';
  }
}

/// @nodoc
abstract mixin class _$AudioTrackCopyWith<$Res>
    implements $AudioTrackCopyWith<$Res> {
  factory _$AudioTrackCopyWith(
          _AudioTrack value, $Res Function(_AudioTrack) _then) =
      __$AudioTrackCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String? title, String? language});
}

/// @nodoc
class __$AudioTrackCopyWithImpl<$Res> implements _$AudioTrackCopyWith<$Res> {
  __$AudioTrackCopyWithImpl(this._self, this._then);

  final _AudioTrack _self;
  final $Res Function(_AudioTrack) _then;

  /// Create a copy of AudioTrack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? language = freezed,
  }) {
    return _then(_AudioTrack(
      null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      freezed == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$SubtitleTrack {
  String get id;
  String? get title;
  String? get language;
  String? get path;

  /// Create a copy of SubtitleTrack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SubtitleTrackCopyWith<SubtitleTrack> get copyWith =>
      _$SubtitleTrackCopyWithImpl<SubtitleTrack>(
          this as SubtitleTrack, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SubtitleTrack &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.path, path) || other.path == path));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, language, path);

  @override
  String toString() {
    return 'SubtitleTrack(id: $id, title: $title, language: $language, path: $path)';
  }
}

/// @nodoc
abstract mixin class $SubtitleTrackCopyWith<$Res> {
  factory $SubtitleTrackCopyWith(
          SubtitleTrack value, $Res Function(SubtitleTrack) _then) =
      _$SubtitleTrackCopyWithImpl;
  @useResult
  $Res call({String id, String? title, String? language, String? path});
}

/// @nodoc
class _$SubtitleTrackCopyWithImpl<$Res>
    implements $SubtitleTrackCopyWith<$Res> {
  _$SubtitleTrackCopyWithImpl(this._self, this._then);

  final SubtitleTrack _self;
  final $Res Function(SubtitleTrack) _then;

  /// Create a copy of SubtitleTrack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? language = freezed,
    Object? path = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      path: freezed == path
          ? _self.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _SubtitleTrack implements SubtitleTrack {
  _SubtitleTrack({required this.id, this.title, this.language, this.path});

  @override
  final String id;
  @override
  final String? title;
  @override
  final String? language;
  @override
  final String? path;

  /// Create a copy of SubtitleTrack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SubtitleTrackCopyWith<_SubtitleTrack> get copyWith =>
      __$SubtitleTrackCopyWithImpl<_SubtitleTrack>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SubtitleTrack &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.path, path) || other.path == path));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, language, path);

  @override
  String toString() {
    return 'SubtitleTrack(id: $id, title: $title, language: $language, path: $path)';
  }
}

/// @nodoc
abstract mixin class _$SubtitleTrackCopyWith<$Res>
    implements $SubtitleTrackCopyWith<$Res> {
  factory _$SubtitleTrackCopyWith(
          _SubtitleTrack value, $Res Function(_SubtitleTrack) _then) =
      __$SubtitleTrackCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String? title, String? language, String? path});
}

/// @nodoc
class __$SubtitleTrackCopyWithImpl<$Res>
    implements _$SubtitleTrackCopyWith<$Res> {
  __$SubtitleTrackCopyWithImpl(this._self, this._then);

  final _SubtitleTrack _self;
  final $Res Function(_SubtitleTrack) _then;

  /// Create a copy of SubtitleTrack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = freezed,
    Object? language = freezed,
    Object? path = freezed,
  }) {
    return _then(_SubtitleTrack(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      path: freezed == path
          ? _self.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
