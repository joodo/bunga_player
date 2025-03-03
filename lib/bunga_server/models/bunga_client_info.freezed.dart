// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bunga_client_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IMInfo _$IMInfoFromJson(Map<String, dynamic> json) {
  return _IMInfo.fromJson(json);
}

/// @nodoc
mixin _$IMInfo {
  String get appId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userSig => throw _privateConstructorUsedError;

  /// Serializes this IMInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IMInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IMInfoCopyWith<IMInfo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IMInfoCopyWith<$Res> {
  factory $IMInfoCopyWith(IMInfo value, $Res Function(IMInfo) then) =
      _$IMInfoCopyWithImpl<$Res, IMInfo>;
  @useResult
  $Res call({String appId, String userId, String userSig});
}

/// @nodoc
class _$IMInfoCopyWithImpl<$Res, $Val extends IMInfo>
    implements $IMInfoCopyWith<$Res> {
  _$IMInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IMInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appId = null,
    Object? userId = null,
    Object? userSig = null,
  }) {
    return _then(_value.copyWith(
      appId: null == appId
          ? _value.appId
          : appId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userSig: null == userSig
          ? _value.userSig
          : userSig // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IMInfoImplCopyWith<$Res> implements $IMInfoCopyWith<$Res> {
  factory _$$IMInfoImplCopyWith(
          _$IMInfoImpl value, $Res Function(_$IMInfoImpl) then) =
      __$$IMInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String appId, String userId, String userSig});
}

/// @nodoc
class __$$IMInfoImplCopyWithImpl<$Res>
    extends _$IMInfoCopyWithImpl<$Res, _$IMInfoImpl>
    implements _$$IMInfoImplCopyWith<$Res> {
  __$$IMInfoImplCopyWithImpl(
      _$IMInfoImpl _value, $Res Function(_$IMInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of IMInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appId = null,
    Object? userId = null,
    Object? userSig = null,
  }) {
    return _then(_$IMInfoImpl(
      appId: null == appId
          ? _value.appId
          : appId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userSig: null == userSig
          ? _value.userSig
          : userSig // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IMInfoImpl implements _IMInfo {
  const _$IMInfoImpl(
      {required this.appId, required this.userId, required this.userSig});

  factory _$IMInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$IMInfoImplFromJson(json);

  @override
  final String appId;
  @override
  final String userId;
  @override
  final String userSig;

  @override
  String toString() {
    return 'IMInfo(appId: $appId, userId: $userId, userSig: $userSig)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IMInfoImpl &&
            (identical(other.appId, appId) || other.appId == appId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userSig, userSig) || other.userSig == userSig));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, appId, userId, userSig);

  /// Create a copy of IMInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IMInfoImplCopyWith<_$IMInfoImpl> get copyWith =>
      __$$IMInfoImplCopyWithImpl<_$IMInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IMInfoImplToJson(
      this,
    );
  }
}

abstract class _IMInfo implements IMInfo {
  const factory _IMInfo(
      {required final String appId,
      required final String userId,
      required final String userSig}) = _$IMInfoImpl;

  factory _IMInfo.fromJson(Map<String, dynamic> json) = _$IMInfoImpl.fromJson;

  @override
  String get appId;
  @override
  String get userId;
  @override
  String get userSig;

  /// Create a copy of IMInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IMInfoImplCopyWith<_$IMInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

VoiceCallInfo _$VoiceCallInfoFromJson(Map<String, dynamic> json) {
  return _VoiceCallInfo.fromJson(json);
}

/// @nodoc
mixin _$VoiceCallInfo {
  String get key => throw _privateConstructorUsedError;

  /// Serializes this VoiceCallInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VoiceCallInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoiceCallInfoCopyWith<VoiceCallInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoiceCallInfoCopyWith<$Res> {
  factory $VoiceCallInfoCopyWith(
          VoiceCallInfo value, $Res Function(VoiceCallInfo) then) =
      _$VoiceCallInfoCopyWithImpl<$Res, VoiceCallInfo>;
  @useResult
  $Res call({String key});
}

/// @nodoc
class _$VoiceCallInfoCopyWithImpl<$Res, $Val extends VoiceCallInfo>
    implements $VoiceCallInfoCopyWith<$Res> {
  _$VoiceCallInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VoiceCallInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VoiceCallInfoImplCopyWith<$Res>
    implements $VoiceCallInfoCopyWith<$Res> {
  factory _$$VoiceCallInfoImplCopyWith(
          _$VoiceCallInfoImpl value, $Res Function(_$VoiceCallInfoImpl) then) =
      __$$VoiceCallInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String key});
}

/// @nodoc
class __$$VoiceCallInfoImplCopyWithImpl<$Res>
    extends _$VoiceCallInfoCopyWithImpl<$Res, _$VoiceCallInfoImpl>
    implements _$$VoiceCallInfoImplCopyWith<$Res> {
  __$$VoiceCallInfoImplCopyWithImpl(
      _$VoiceCallInfoImpl _value, $Res Function(_$VoiceCallInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of VoiceCallInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
  }) {
    return _then(_$VoiceCallInfoImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VoiceCallInfoImpl implements _VoiceCallInfo {
  const _$VoiceCallInfoImpl({required this.key});

  factory _$VoiceCallInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoiceCallInfoImplFromJson(json);

  @override
  final String key;

  @override
  String toString() {
    return 'VoiceCallInfo(key: $key)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoiceCallInfoImpl &&
            (identical(other.key, key) || other.key == key));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, key);

  /// Create a copy of VoiceCallInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoiceCallInfoImplCopyWith<_$VoiceCallInfoImpl> get copyWith =>
      __$$VoiceCallInfoImplCopyWithImpl<_$VoiceCallInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoiceCallInfoImplToJson(
      this,
    );
  }
}

abstract class _VoiceCallInfo implements VoiceCallInfo {
  const factory _VoiceCallInfo({required final String key}) =
      _$VoiceCallInfoImpl;

  factory _VoiceCallInfo.fromJson(Map<String, dynamic> json) =
      _$VoiceCallInfoImpl.fromJson;

  @override
  String get key;

  /// Create a copy of VoiceCallInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoiceCallInfoImplCopyWith<_$VoiceCallInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BilibiliInfo _$BilibiliInfoFromJson(Map<String, dynamic> json) {
  return _BilibiliInfo.fromJson(json);
}

/// @nodoc
mixin _$BilibiliInfo {
  String get sess => throw _privateConstructorUsedError;
  String get mixinKey => throw _privateConstructorUsedError;

  /// Serializes this BilibiliInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BilibiliInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BilibiliInfoCopyWith<BilibiliInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BilibiliInfoCopyWith<$Res> {
  factory $BilibiliInfoCopyWith(
          BilibiliInfo value, $Res Function(BilibiliInfo) then) =
      _$BilibiliInfoCopyWithImpl<$Res, BilibiliInfo>;
  @useResult
  $Res call({String sess, String mixinKey});
}

/// @nodoc
class _$BilibiliInfoCopyWithImpl<$Res, $Val extends BilibiliInfo>
    implements $BilibiliInfoCopyWith<$Res> {
  _$BilibiliInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BilibiliInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sess = null,
    Object? mixinKey = null,
  }) {
    return _then(_value.copyWith(
      sess: null == sess
          ? _value.sess
          : sess // ignore: cast_nullable_to_non_nullable
              as String,
      mixinKey: null == mixinKey
          ? _value.mixinKey
          : mixinKey // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BilibiliInfoImplCopyWith<$Res>
    implements $BilibiliInfoCopyWith<$Res> {
  factory _$$BilibiliInfoImplCopyWith(
          _$BilibiliInfoImpl value, $Res Function(_$BilibiliInfoImpl) then) =
      __$$BilibiliInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String sess, String mixinKey});
}

/// @nodoc
class __$$BilibiliInfoImplCopyWithImpl<$Res>
    extends _$BilibiliInfoCopyWithImpl<$Res, _$BilibiliInfoImpl>
    implements _$$BilibiliInfoImplCopyWith<$Res> {
  __$$BilibiliInfoImplCopyWithImpl(
      _$BilibiliInfoImpl _value, $Res Function(_$BilibiliInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of BilibiliInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sess = null,
    Object? mixinKey = null,
  }) {
    return _then(_$BilibiliInfoImpl(
      sess: null == sess
          ? _value.sess
          : sess // ignore: cast_nullable_to_non_nullable
              as String,
      mixinKey: null == mixinKey
          ? _value.mixinKey
          : mixinKey // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BilibiliInfoImpl implements _BilibiliInfo {
  const _$BilibiliInfoImpl({required this.sess, required this.mixinKey});

  factory _$BilibiliInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$BilibiliInfoImplFromJson(json);

  @override
  final String sess;
  @override
  final String mixinKey;

  @override
  String toString() {
    return 'BilibiliInfo(sess: $sess, mixinKey: $mixinKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BilibiliInfoImpl &&
            (identical(other.sess, sess) || other.sess == sess) &&
            (identical(other.mixinKey, mixinKey) ||
                other.mixinKey == mixinKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, sess, mixinKey);

  /// Create a copy of BilibiliInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BilibiliInfoImplCopyWith<_$BilibiliInfoImpl> get copyWith =>
      __$$BilibiliInfoImplCopyWithImpl<_$BilibiliInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BilibiliInfoImplToJson(
      this,
    );
  }
}

abstract class _BilibiliInfo implements BilibiliInfo {
  const factory _BilibiliInfo(
      {required final String sess,
      required final String mixinKey}) = _$BilibiliInfoImpl;

  factory _BilibiliInfo.fromJson(Map<String, dynamic> json) =
      _$BilibiliInfoImpl.fromJson;

  @override
  String get sess;
  @override
  String get mixinKey;

  /// Create a copy of BilibiliInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BilibiliInfoImplCopyWith<_$BilibiliInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AListInfo _$AListInfoFromJson(Map<String, dynamic> json) {
  return _AListInfo.fromJson(json);
}

/// @nodoc
mixin _$AListInfo {
  String get host => throw _privateConstructorUsedError;
  String get token => throw _privateConstructorUsedError;

  /// Serializes this AListInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AListInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AListInfoCopyWith<AListInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AListInfoCopyWith<$Res> {
  factory $AListInfoCopyWith(AListInfo value, $Res Function(AListInfo) then) =
      _$AListInfoCopyWithImpl<$Res, AListInfo>;
  @useResult
  $Res call({String host, String token});
}

/// @nodoc
class _$AListInfoCopyWithImpl<$Res, $Val extends AListInfo>
    implements $AListInfoCopyWith<$Res> {
  _$AListInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AListInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? host = null,
    Object? token = null,
  }) {
    return _then(_value.copyWith(
      host: null == host
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AListInfoImplCopyWith<$Res>
    implements $AListInfoCopyWith<$Res> {
  factory _$$AListInfoImplCopyWith(
          _$AListInfoImpl value, $Res Function(_$AListInfoImpl) then) =
      __$$AListInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String host, String token});
}

/// @nodoc
class __$$AListInfoImplCopyWithImpl<$Res>
    extends _$AListInfoCopyWithImpl<$Res, _$AListInfoImpl>
    implements _$$AListInfoImplCopyWith<$Res> {
  __$$AListInfoImplCopyWithImpl(
      _$AListInfoImpl _value, $Res Function(_$AListInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of AListInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? host = null,
    Object? token = null,
  }) {
    return _then(_$AListInfoImpl(
      host: null == host
          ? _value.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AListInfoImpl implements _AListInfo {
  const _$AListInfoImpl({required this.host, required this.token});

  factory _$AListInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AListInfoImplFromJson(json);

  @override
  final String host;
  @override
  final String token;

  @override
  String toString() {
    return 'AListInfo(host: $host, token: $token)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AListInfoImpl &&
            (identical(other.host, host) || other.host == host) &&
            (identical(other.token, token) || other.token == token));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, host, token);

  /// Create a copy of AListInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AListInfoImplCopyWith<_$AListInfoImpl> get copyWith =>
      __$$AListInfoImplCopyWithImpl<_$AListInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AListInfoImplToJson(
      this,
    );
  }
}

abstract class _AListInfo implements AListInfo {
  const factory _AListInfo(
      {required final String host,
      required final String token}) = _$AListInfoImpl;

  factory _AListInfo.fromJson(Map<String, dynamic> json) =
      _$AListInfoImpl.fromJson;

  @override
  String get host;
  @override
  String get token;

  /// Create a copy of AListInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AListInfoImplCopyWith<_$AListInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChannelInfo _$ChannelInfoFromJson(Map<String, dynamic> json) {
  return _ChannelInfo.fromJson(json);
}

/// @nodoc
mixin _$ChannelInfo {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this ChannelInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChannelInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChannelInfoCopyWith<ChannelInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChannelInfoCopyWith<$Res> {
  factory $ChannelInfoCopyWith(
          ChannelInfo value, $Res Function(ChannelInfo) then) =
      _$ChannelInfoCopyWithImpl<$Res, ChannelInfo>;
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class _$ChannelInfoCopyWithImpl<$Res, $Val extends ChannelInfo>
    implements $ChannelInfoCopyWith<$Res> {
  _$ChannelInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChannelInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChannelInfoImplCopyWith<$Res>
    implements $ChannelInfoCopyWith<$Res> {
  factory _$$ChannelInfoImplCopyWith(
          _$ChannelInfoImpl value, $Res Function(_$ChannelInfoImpl) then) =
      __$$ChannelInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class __$$ChannelInfoImplCopyWithImpl<$Res>
    extends _$ChannelInfoCopyWithImpl<$Res, _$ChannelInfoImpl>
    implements _$$ChannelInfoImplCopyWith<$Res> {
  __$$ChannelInfoImplCopyWithImpl(
      _$ChannelInfoImpl _value, $Res Function(_$ChannelInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChannelInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_$ChannelInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChannelInfoImpl implements _ChannelInfo {
  const _$ChannelInfoImpl({required this.id, required this.name});

  factory _$ChannelInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChannelInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;

  @override
  String toString() {
    return 'ChannelInfo(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChannelInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of ChannelInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChannelInfoImplCopyWith<_$ChannelInfoImpl> get copyWith =>
      __$$ChannelInfoImplCopyWithImpl<_$ChannelInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChannelInfoImplToJson(
      this,
    );
  }
}

abstract class _ChannelInfo implements ChannelInfo {
  const factory _ChannelInfo(
      {required final String id,
      required final String name}) = _$ChannelInfoImpl;

  factory _ChannelInfo.fromJson(Map<String, dynamic> json) =
      _$ChannelInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;

  /// Create a copy of ChannelInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChannelInfoImplCopyWith<_$ChannelInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BungaClientInfo _$BungaClientInfoFromJson(Map<String, dynamic> json) {
  return _BungaClientInfo.fromJson(json);
}

/// @nodoc
mixin _$BungaClientInfo {
  String get token => throw _privateConstructorUsedError;
  ChannelInfo get channel => throw _privateConstructorUsedError;
  IMInfo get im => throw _privateConstructorUsedError;
  VoiceCallInfo? get voiceCall => throw _privateConstructorUsedError;
  BilibiliInfo? get bilibili => throw _privateConstructorUsedError;
  AListInfo? get alist => throw _privateConstructorUsedError;

  /// Serializes this BungaClientInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BungaClientInfoCopyWith<BungaClientInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BungaClientInfoCopyWith<$Res> {
  factory $BungaClientInfoCopyWith(
          BungaClientInfo value, $Res Function(BungaClientInfo) then) =
      _$BungaClientInfoCopyWithImpl<$Res, BungaClientInfo>;
  @useResult
  $Res call(
      {String token,
      ChannelInfo channel,
      IMInfo im,
      VoiceCallInfo? voiceCall,
      BilibiliInfo? bilibili,
      AListInfo? alist});

  $ChannelInfoCopyWith<$Res> get channel;
  $IMInfoCopyWith<$Res> get im;
  $VoiceCallInfoCopyWith<$Res>? get voiceCall;
  $BilibiliInfoCopyWith<$Res>? get bilibili;
  $AListInfoCopyWith<$Res>? get alist;
}

/// @nodoc
class _$BungaClientInfoCopyWithImpl<$Res, $Val extends BungaClientInfo>
    implements $BungaClientInfoCopyWith<$Res> {
  _$BungaClientInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? channel = null,
    Object? im = null,
    Object? voiceCall = freezed,
    Object? bilibili = freezed,
    Object? alist = freezed,
  }) {
    return _then(_value.copyWith(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      channel: null == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as ChannelInfo,
      im: null == im
          ? _value.im
          : im // ignore: cast_nullable_to_non_nullable
              as IMInfo,
      voiceCall: freezed == voiceCall
          ? _value.voiceCall
          : voiceCall // ignore: cast_nullable_to_non_nullable
              as VoiceCallInfo?,
      bilibili: freezed == bilibili
          ? _value.bilibili
          : bilibili // ignore: cast_nullable_to_non_nullable
              as BilibiliInfo?,
      alist: freezed == alist
          ? _value.alist
          : alist // ignore: cast_nullable_to_non_nullable
              as AListInfo?,
    ) as $Val);
  }

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChannelInfoCopyWith<$Res> get channel {
    return $ChannelInfoCopyWith<$Res>(_value.channel, (value) {
      return _then(_value.copyWith(channel: value) as $Val);
    });
  }

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IMInfoCopyWith<$Res> get im {
    return $IMInfoCopyWith<$Res>(_value.im, (value) {
      return _then(_value.copyWith(im: value) as $Val);
    });
  }

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VoiceCallInfoCopyWith<$Res>? get voiceCall {
    if (_value.voiceCall == null) {
      return null;
    }

    return $VoiceCallInfoCopyWith<$Res>(_value.voiceCall!, (value) {
      return _then(_value.copyWith(voiceCall: value) as $Val);
    });
  }

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BilibiliInfoCopyWith<$Res>? get bilibili {
    if (_value.bilibili == null) {
      return null;
    }

    return $BilibiliInfoCopyWith<$Res>(_value.bilibili!, (value) {
      return _then(_value.copyWith(bilibili: value) as $Val);
    });
  }

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AListInfoCopyWith<$Res>? get alist {
    if (_value.alist == null) {
      return null;
    }

    return $AListInfoCopyWith<$Res>(_value.alist!, (value) {
      return _then(_value.copyWith(alist: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BungaClientInfoImplCopyWith<$Res>
    implements $BungaClientInfoCopyWith<$Res> {
  factory _$$BungaClientInfoImplCopyWith(_$BungaClientInfoImpl value,
          $Res Function(_$BungaClientInfoImpl) then) =
      __$$BungaClientInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String token,
      ChannelInfo channel,
      IMInfo im,
      VoiceCallInfo? voiceCall,
      BilibiliInfo? bilibili,
      AListInfo? alist});

  @override
  $ChannelInfoCopyWith<$Res> get channel;
  @override
  $IMInfoCopyWith<$Res> get im;
  @override
  $VoiceCallInfoCopyWith<$Res>? get voiceCall;
  @override
  $BilibiliInfoCopyWith<$Res>? get bilibili;
  @override
  $AListInfoCopyWith<$Res>? get alist;
}

/// @nodoc
class __$$BungaClientInfoImplCopyWithImpl<$Res>
    extends _$BungaClientInfoCopyWithImpl<$Res, _$BungaClientInfoImpl>
    implements _$$BungaClientInfoImplCopyWith<$Res> {
  __$$BungaClientInfoImplCopyWithImpl(
      _$BungaClientInfoImpl _value, $Res Function(_$BungaClientInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? channel = null,
    Object? im = null,
    Object? voiceCall = freezed,
    Object? bilibili = freezed,
    Object? alist = freezed,
  }) {
    return _then(_$BungaClientInfoImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      channel: null == channel
          ? _value.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as ChannelInfo,
      im: null == im
          ? _value.im
          : im // ignore: cast_nullable_to_non_nullable
              as IMInfo,
      voiceCall: freezed == voiceCall
          ? _value.voiceCall
          : voiceCall // ignore: cast_nullable_to_non_nullable
              as VoiceCallInfo?,
      bilibili: freezed == bilibili
          ? _value.bilibili
          : bilibili // ignore: cast_nullable_to_non_nullable
              as BilibiliInfo?,
      alist: freezed == alist
          ? _value.alist
          : alist // ignore: cast_nullable_to_non_nullable
              as AListInfo?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BungaClientInfoImpl implements _BungaClientInfo {
  const _$BungaClientInfoImpl(
      {required this.token,
      required this.channel,
      required this.im,
      this.voiceCall,
      this.bilibili,
      this.alist});

  factory _$BungaClientInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$BungaClientInfoImplFromJson(json);

  @override
  final String token;
  @override
  final ChannelInfo channel;
  @override
  final IMInfo im;
  @override
  final VoiceCallInfo? voiceCall;
  @override
  final BilibiliInfo? bilibili;
  @override
  final AListInfo? alist;

  @override
  String toString() {
    return 'BungaClientInfo(token: $token, channel: $channel, im: $im, voiceCall: $voiceCall, bilibili: $bilibili, alist: $alist)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BungaClientInfoImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.im, im) || other.im == im) &&
            (identical(other.voiceCall, voiceCall) ||
                other.voiceCall == voiceCall) &&
            (identical(other.bilibili, bilibili) ||
                other.bilibili == bilibili) &&
            (identical(other.alist, alist) || other.alist == alist));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, token, channel, im, voiceCall, bilibili, alist);

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BungaClientInfoImplCopyWith<_$BungaClientInfoImpl> get copyWith =>
      __$$BungaClientInfoImplCopyWithImpl<_$BungaClientInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BungaClientInfoImplToJson(
      this,
    );
  }
}

abstract class _BungaClientInfo implements BungaClientInfo {
  const factory _BungaClientInfo(
      {required final String token,
      required final ChannelInfo channel,
      required final IMInfo im,
      final VoiceCallInfo? voiceCall,
      final BilibiliInfo? bilibili,
      final AListInfo? alist}) = _$BungaClientInfoImpl;

  factory _BungaClientInfo.fromJson(Map<String, dynamic> json) =
      _$BungaClientInfoImpl.fromJson;

  @override
  String get token;
  @override
  ChannelInfo get channel;
  @override
  IMInfo get im;
  @override
  VoiceCallInfo? get voiceCall;
  @override
  BilibiliInfo? get bilibili;
  @override
  AListInfo? get alist;

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BungaClientInfoImplCopyWith<_$BungaClientInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
