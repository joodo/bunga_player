// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'play_payload.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VideoSources {

 List<String> get videos; List<String>? get audios; Map<String, String>? get requestHeaders;
/// Create a copy of VideoSources
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoSourcesCopyWith<VideoSources> get copyWith => _$VideoSourcesCopyWithImpl<VideoSources>(this as VideoSources, _$identity);

  /// Serializes this VideoSources to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoSources&&const DeepCollectionEquality().equals(other.videos, videos)&&const DeepCollectionEquality().equals(other.audios, audios)&&const DeepCollectionEquality().equals(other.requestHeaders, requestHeaders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(videos),const DeepCollectionEquality().hash(audios),const DeepCollectionEquality().hash(requestHeaders));

@override
String toString() {
  return 'VideoSources(videos: $videos, audios: $audios, requestHeaders: $requestHeaders)';
}


}

/// @nodoc
abstract mixin class $VideoSourcesCopyWith<$Res>  {
  factory $VideoSourcesCopyWith(VideoSources value, $Res Function(VideoSources) _then) = _$VideoSourcesCopyWithImpl;
@useResult
$Res call({
 List<String> videos, List<String>? audios, Map<String, String>? requestHeaders
});




}
/// @nodoc
class _$VideoSourcesCopyWithImpl<$Res>
    implements $VideoSourcesCopyWith<$Res> {
  _$VideoSourcesCopyWithImpl(this._self, this._then);

  final VideoSources _self;
  final $Res Function(VideoSources) _then;

/// Create a copy of VideoSources
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? videos = null,Object? audios = freezed,Object? requestHeaders = freezed,}) {
  return _then(_self.copyWith(
videos: null == videos ? _self.videos : videos // ignore: cast_nullable_to_non_nullable
as List<String>,audios: freezed == audios ? _self.audios : audios // ignore: cast_nullable_to_non_nullable
as List<String>?,requestHeaders: freezed == requestHeaders ? _self.requestHeaders : requestHeaders // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoSources].
extension VideoSourcesPatterns on VideoSources {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoSources value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoSources() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoSources value)  $default,){
final _that = this;
switch (_that) {
case _VideoSources():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoSources value)?  $default,){
final _that = this;
switch (_that) {
case _VideoSources() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> videos,  List<String>? audios,  Map<String, String>? requestHeaders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoSources() when $default != null:
return $default(_that.videos,_that.audios,_that.requestHeaders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> videos,  List<String>? audios,  Map<String, String>? requestHeaders)  $default,) {final _that = this;
switch (_that) {
case _VideoSources():
return $default(_that.videos,_that.audios,_that.requestHeaders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> videos,  List<String>? audios,  Map<String, String>? requestHeaders)?  $default,) {final _that = this;
switch (_that) {
case _VideoSources() when $default != null:
return $default(_that.videos,_that.audios,_that.requestHeaders);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoSources extends VideoSources {
  const _VideoSources({required final  List<String> videos, final  List<String>? audios, final  Map<String, String>? requestHeaders}): _videos = videos,_audios = audios,_requestHeaders = requestHeaders,super._();
  factory _VideoSources.fromJson(Map<String, dynamic> json) => _$VideoSourcesFromJson(json);

 final  List<String> _videos;
@override List<String> get videos {
  if (_videos is EqualUnmodifiableListView) return _videos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_videos);
}

 final  List<String>? _audios;
@override List<String>? get audios {
  final value = _audios;
  if (value == null) return null;
  if (_audios is EqualUnmodifiableListView) return _audios;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, String>? _requestHeaders;
@override Map<String, String>? get requestHeaders {
  final value = _requestHeaders;
  if (value == null) return null;
  if (_requestHeaders is EqualUnmodifiableMapView) return _requestHeaders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of VideoSources
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoSourcesCopyWith<_VideoSources> get copyWith => __$VideoSourcesCopyWithImpl<_VideoSources>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoSourcesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoSources&&const DeepCollectionEquality().equals(other._videos, _videos)&&const DeepCollectionEquality().equals(other._audios, _audios)&&const DeepCollectionEquality().equals(other._requestHeaders, _requestHeaders));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_videos),const DeepCollectionEquality().hash(_audios),const DeepCollectionEquality().hash(_requestHeaders));

@override
String toString() {
  return 'VideoSources(videos: $videos, audios: $audios, requestHeaders: $requestHeaders)';
}


}

/// @nodoc
abstract mixin class _$VideoSourcesCopyWith<$Res> implements $VideoSourcesCopyWith<$Res> {
  factory _$VideoSourcesCopyWith(_VideoSources value, $Res Function(_VideoSources) _then) = __$VideoSourcesCopyWithImpl;
@override @useResult
$Res call({
 List<String> videos, List<String>? audios, Map<String, String>? requestHeaders
});




}
/// @nodoc
class __$VideoSourcesCopyWithImpl<$Res>
    implements _$VideoSourcesCopyWith<$Res> {
  __$VideoSourcesCopyWithImpl(this._self, this._then);

  final _VideoSources _self;
  final $Res Function(_VideoSources) _then;

/// Create a copy of VideoSources
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? videos = null,Object? audios = freezed,Object? requestHeaders = freezed,}) {
  return _then(_VideoSources(
videos: null == videos ? _self._videos : videos // ignore: cast_nullable_to_non_nullable
as List<String>,audios: freezed == audios ? _self._audios : audios // ignore: cast_nullable_to_non_nullable
as List<String>?,requestHeaders: freezed == requestHeaders ? _self._requestHeaders : requestHeaders // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}


}


/// @nodoc
mixin _$PlayPayload {

 VideoRecord get record; VideoSources get sources; int get videoSourceIndex;
/// Create a copy of PlayPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayPayloadCopyWith<PlayPayload> get copyWith => _$PlayPayloadCopyWithImpl<PlayPayload>(this as PlayPayload, _$identity);

  /// Serializes this PlayPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayPayload&&(identical(other.record, record) || other.record == record)&&(identical(other.sources, sources) || other.sources == sources)&&(identical(other.videoSourceIndex, videoSourceIndex) || other.videoSourceIndex == videoSourceIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,record,sources,videoSourceIndex);



}

/// @nodoc
abstract mixin class $PlayPayloadCopyWith<$Res>  {
  factory $PlayPayloadCopyWith(PlayPayload value, $Res Function(PlayPayload) _then) = _$PlayPayloadCopyWithImpl;
@useResult
$Res call({
 VideoRecord record, VideoSources sources, int videoSourceIndex
});


$VideoRecordCopyWith<$Res> get record;$VideoSourcesCopyWith<$Res> get sources;

}
/// @nodoc
class _$PlayPayloadCopyWithImpl<$Res>
    implements $PlayPayloadCopyWith<$Res> {
  _$PlayPayloadCopyWithImpl(this._self, this._then);

  final PlayPayload _self;
  final $Res Function(PlayPayload) _then;

/// Create a copy of PlayPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? record = null,Object? sources = null,Object? videoSourceIndex = null,}) {
  return _then(_self.copyWith(
record: null == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as VideoRecord,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as VideoSources,videoSourceIndex: null == videoSourceIndex ? _self.videoSourceIndex : videoSourceIndex // ignore: cast_nullable_to_non_nullable
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
}/// Create a copy of PlayPayload
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoSourcesCopyWith<$Res> get sources {
  
  return $VideoSourcesCopyWith<$Res>(_self.sources, (value) {
    return _then(_self.copyWith(sources: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlayPayload].
extension PlayPayloadPatterns on PlayPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlayPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlayPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlayPayload value)  $default,){
final _that = this;
switch (_that) {
case _PlayPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlayPayload value)?  $default,){
final _that = this;
switch (_that) {
case _PlayPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VideoRecord record,  VideoSources sources,  int videoSourceIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlayPayload() when $default != null:
return $default(_that.record,_that.sources,_that.videoSourceIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VideoRecord record,  VideoSources sources,  int videoSourceIndex)  $default,) {final _that = this;
switch (_that) {
case _PlayPayload():
return $default(_that.record,_that.sources,_that.videoSourceIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VideoRecord record,  VideoSources sources,  int videoSourceIndex)?  $default,) {final _that = this;
switch (_that) {
case _PlayPayload() when $default != null:
return $default(_that.record,_that.sources,_that.videoSourceIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlayPayload extends PlayPayload {
  const _PlayPayload({required this.record, required this.sources, this.videoSourceIndex = 0}): super._();
  factory _PlayPayload.fromJson(Map<String, dynamic> json) => _$PlayPayloadFromJson(json);

@override final  VideoRecord record;
@override final  VideoSources sources;
@override@JsonKey() final  int videoSourceIndex;

/// Create a copy of PlayPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayPayloadCopyWith<_PlayPayload> get copyWith => __$PlayPayloadCopyWithImpl<_PlayPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlayPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayPayload&&(identical(other.record, record) || other.record == record)&&(identical(other.sources, sources) || other.sources == sources)&&(identical(other.videoSourceIndex, videoSourceIndex) || other.videoSourceIndex == videoSourceIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,record,sources,videoSourceIndex);



}

/// @nodoc
abstract mixin class _$PlayPayloadCopyWith<$Res> implements $PlayPayloadCopyWith<$Res> {
  factory _$PlayPayloadCopyWith(_PlayPayload value, $Res Function(_PlayPayload) _then) = __$PlayPayloadCopyWithImpl;
@override @useResult
$Res call({
 VideoRecord record, VideoSources sources, int videoSourceIndex
});


@override $VideoRecordCopyWith<$Res> get record;@override $VideoSourcesCopyWith<$Res> get sources;

}
/// @nodoc
class __$PlayPayloadCopyWithImpl<$Res>
    implements _$PlayPayloadCopyWith<$Res> {
  __$PlayPayloadCopyWithImpl(this._self, this._then);

  final _PlayPayload _self;
  final $Res Function(_PlayPayload) _then;

/// Create a copy of PlayPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? record = null,Object? sources = null,Object? videoSourceIndex = null,}) {
  return _then(_PlayPayload(
record: null == record ? _self.record : record // ignore: cast_nullable_to_non_nullable
as VideoRecord,sources: null == sources ? _self.sources : sources // ignore: cast_nullable_to_non_nullable
as VideoSources,videoSourceIndex: null == videoSourceIndex ? _self.videoSourceIndex : videoSourceIndex // ignore: cast_nullable_to_non_nullable
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
}/// Create a copy of PlayPayload
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VideoSourcesCopyWith<$Res> get sources {
  
  return $VideoSourcesCopyWith<$Res>(_self.sources, (value) {
    return _then(_self.copyWith(sources: value));
  });
}
}

// dart format on
