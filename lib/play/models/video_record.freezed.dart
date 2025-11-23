// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VideoRecord {

@JsonKey(name: 'record_id') String get id; String get title; String? get thumbUrl; String get source; String get path;
/// Create a copy of VideoRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoRecordCopyWith<VideoRecord> get copyWith => _$VideoRecordCopyWithImpl<VideoRecord>(this as VideoRecord, _$identity);

  /// Serializes this VideoRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.thumbUrl, thumbUrl) || other.thumbUrl == thumbUrl)&&(identical(other.source, source) || other.source == source)&&(identical(other.path, path) || other.path == path));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,thumbUrl,source,path);

@override
String toString() {
  return 'VideoRecord(id: $id, title: $title, thumbUrl: $thumbUrl, source: $source, path: $path)';
}


}

/// @nodoc
abstract mixin class $VideoRecordCopyWith<$Res>  {
  factory $VideoRecordCopyWith(VideoRecord value, $Res Function(VideoRecord) _then) = _$VideoRecordCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'record_id') String id, String title, String? thumbUrl, String source, String path
});




}
/// @nodoc
class _$VideoRecordCopyWithImpl<$Res>
    implements $VideoRecordCopyWith<$Res> {
  _$VideoRecordCopyWithImpl(this._self, this._then);

  final VideoRecord _self;
  final $Res Function(VideoRecord) _then;

/// Create a copy of VideoRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? thumbUrl = freezed,Object? source = null,Object? path = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,thumbUrl: freezed == thumbUrl ? _self.thumbUrl : thumbUrl // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoRecord].
extension VideoRecordPatterns on VideoRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoRecord() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoRecord value)  $default,){
final _that = this;
switch (_that) {
case _VideoRecord():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoRecord value)?  $default,){
final _that = this;
switch (_that) {
case _VideoRecord() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'record_id')  String id,  String title,  String? thumbUrl,  String source,  String path)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoRecord() when $default != null:
return $default(_that.id,_that.title,_that.thumbUrl,_that.source,_that.path);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'record_id')  String id,  String title,  String? thumbUrl,  String source,  String path)  $default,) {final _that = this;
switch (_that) {
case _VideoRecord():
return $default(_that.id,_that.title,_that.thumbUrl,_that.source,_that.path);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'record_id')  String id,  String title,  String? thumbUrl,  String source,  String path)?  $default,) {final _that = this;
switch (_that) {
case _VideoRecord() when $default != null:
return $default(_that.id,_that.title,_that.thumbUrl,_that.source,_that.path);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoRecord implements VideoRecord {
  const _VideoRecord({@JsonKey(name: 'record_id') required this.id, required this.title, this.thumbUrl, required this.source, required this.path});
  factory _VideoRecord.fromJson(Map<String, dynamic> json) => _$VideoRecordFromJson(json);

@override@JsonKey(name: 'record_id') final  String id;
@override final  String title;
@override final  String? thumbUrl;
@override final  String source;
@override final  String path;

/// Create a copy of VideoRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoRecordCopyWith<_VideoRecord> get copyWith => __$VideoRecordCopyWithImpl<_VideoRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.thumbUrl, thumbUrl) || other.thumbUrl == thumbUrl)&&(identical(other.source, source) || other.source == source)&&(identical(other.path, path) || other.path == path));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,thumbUrl,source,path);

@override
String toString() {
  return 'VideoRecord(id: $id, title: $title, thumbUrl: $thumbUrl, source: $source, path: $path)';
}


}

/// @nodoc
abstract mixin class _$VideoRecordCopyWith<$Res> implements $VideoRecordCopyWith<$Res> {
  factory _$VideoRecordCopyWith(_VideoRecord value, $Res Function(_VideoRecord) _then) = __$VideoRecordCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'record_id') String id, String title, String? thumbUrl, String source, String path
});




}
/// @nodoc
class __$VideoRecordCopyWithImpl<$Res>
    implements _$VideoRecordCopyWith<$Res> {
  __$VideoRecordCopyWithImpl(this._self, this._then);

  final _VideoRecord _self;
  final $Res Function(_VideoRecord) _then;

/// Create a copy of VideoRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? thumbUrl = freezed,Object? source = null,Object? path = null,}) {
  return _then(_VideoRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,thumbUrl: freezed == thumbUrl ? _self.thumbUrl : thumbUrl // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
