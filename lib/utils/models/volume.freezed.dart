// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
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

 double get level; bool get mute;
/// Create a copy of Volume
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VolumeCopyWith<Volume> get copyWith => _$VolumeCopyWithImpl<Volume>(this as Volume, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Volume&&(identical(other.level, level) || other.level == level)&&(identical(other.mute, mute) || other.mute == mute));
}


@override
int get hashCode => Object.hash(runtimeType,level,mute);

@override
String toString() {
  return 'Volume(level: $level, mute: $mute)';
}


}

/// @nodoc
abstract mixin class $VolumeCopyWith<$Res>  {
  factory $VolumeCopyWith(Volume value, $Res Function(Volume) _then) = _$VolumeCopyWithImpl;
@useResult
$Res call({
 double level, bool mute
});




}
/// @nodoc
class _$VolumeCopyWithImpl<$Res>
    implements $VolumeCopyWith<$Res> {
  _$VolumeCopyWithImpl(this._self, this._then);

  final Volume _self;
  final $Res Function(Volume) _then;

/// Create a copy of Volume
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level = null,Object? mute = null,}) {
  return _then(_self.copyWith(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as double,mute: null == mute ? _self.mute : mute // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Volume].
extension VolumePatterns on Volume {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Volume value)?  raw,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Volume() when raw != null:
return raw(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Volume value)  raw,}){
final _that = this;
switch (_that) {
case _Volume():
return raw(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Volume value)?  raw,}){
final _that = this;
switch (_that) {
case _Volume() when raw != null:
return raw(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( double level,  bool mute)?  raw,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Volume() when raw != null:
return raw(_that.level,_that.mute);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( double level,  bool mute)  raw,}) {final _that = this;
switch (_that) {
case _Volume():
return raw(_that.level,_that.mute);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( double level,  bool mute)?  raw,}) {final _that = this;
switch (_that) {
case _Volume() when raw != null:
return raw(_that.level,_that.mute);case _:
  return null;

}
}

}

/// @nodoc


class _Volume extends Volume {
  const _Volume({required this.level, required this.mute}): super._();
  

@override final  double level;
@override final  bool mute;

/// Create a copy of Volume
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VolumeCopyWith<_Volume> get copyWith => __$VolumeCopyWithImpl<_Volume>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Volume&&(identical(other.level, level) || other.level == level)&&(identical(other.mute, mute) || other.mute == mute));
}


@override
int get hashCode => Object.hash(runtimeType,level,mute);

@override
String toString() {
  return 'Volume.raw(level: $level, mute: $mute)';
}


}

/// @nodoc
abstract mixin class _$VolumeCopyWith<$Res> implements $VolumeCopyWith<$Res> {
  factory _$VolumeCopyWith(_Volume value, $Res Function(_Volume) _then) = __$VolumeCopyWithImpl;
@override @useResult
$Res call({
 double level, bool mute
});




}
/// @nodoc
class __$VolumeCopyWithImpl<$Res>
    implements _$VolumeCopyWith<$Res> {
  __$VolumeCopyWithImpl(this._self, this._then);

  final _Volume _self;
  final $Res Function(_Volume) _then;

/// Create a copy of Volume
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level = null,Object? mute = null,}) {
  return _then(_Volume(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as double,mute: null == mute ? _self.mute : mute // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
