// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'volume.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Volume {
  int get volume;
  bool get mute;

  /// Create a copy of Volume
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VolumeCopyWith<Volume> get copyWith =>
      _$VolumeCopyWithImpl<Volume>(this as Volume, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Volume &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.mute, mute) || other.mute == mute));
  }

  @override
  int get hashCode => Object.hash(runtimeType, volume, mute);

  @override
  String toString() {
    return 'Volume(volume: $volume, mute: $mute)';
  }
}

/// @nodoc
abstract mixin class $VolumeCopyWith<$Res> {
  factory $VolumeCopyWith(Volume value, $Res Function(Volume) _then) =
      _$VolumeCopyWithImpl;
  @useResult
  $Res call({int volume, bool mute});
}

/// @nodoc
class _$VolumeCopyWithImpl<$Res> implements $VolumeCopyWith<$Res> {
  _$VolumeCopyWithImpl(this._self, this._then);

  final Volume _self;
  final $Res Function(Volume) _then;

  /// Create a copy of Volume
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? volume = null,
    Object? mute = null,
  }) {
    return _then(_self.copyWith(
      volume: null == volume
          ? _self.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as int,
      mute: null == mute
          ? _self.mute
          : mute // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _Volume implements Volume {
  _Volume({required this.volume, this.mute = false});

  @override
  final int volume;
  @override
  @JsonKey()
  final bool mute;

  /// Create a copy of Volume
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$VolumeCopyWith<_Volume> get copyWith =>
      __$VolumeCopyWithImpl<_Volume>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Volume &&
            (identical(other.volume, volume) || other.volume == volume) &&
            (identical(other.mute, mute) || other.mute == mute));
  }

  @override
  int get hashCode => Object.hash(runtimeType, volume, mute);

  @override
  String toString() {
    return 'Volume(volume: $volume, mute: $mute)';
  }
}

/// @nodoc
abstract mixin class _$VolumeCopyWith<$Res> implements $VolumeCopyWith<$Res> {
  factory _$VolumeCopyWith(_Volume value, $Res Function(_Volume) _then) =
      __$VolumeCopyWithImpl;
  @override
  @useResult
  $Res call({int volume, bool mute});
}

/// @nodoc
class __$VolumeCopyWithImpl<$Res> implements _$VolumeCopyWith<$Res> {
  __$VolumeCopyWithImpl(this._self, this._then);

  final _Volume _self;
  final $Res Function(_Volume) _then;

  /// Create a copy of Volume
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? volume = null,
    Object? mute = null,
  }) {
    return _then(_Volume(
      volume: null == volume
          ? _self.volume
          : volume // ignore: cast_nullable_to_non_nullable
              as int,
      mute: null == mute
          ? _self.mute
          : mute // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
