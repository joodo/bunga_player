// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bunga_client_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IMInfo {
  String get appId;
  String get userId;
  String get userSig;

  /// Create a copy of IMInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $IMInfoCopyWith<IMInfo> get copyWith =>
      _$IMInfoCopyWithImpl<IMInfo>(this as IMInfo, _$identity);

  /// Serializes this IMInfo to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is IMInfo &&
            (identical(other.appId, appId) || other.appId == appId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userSig, userSig) || other.userSig == userSig));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, appId, userId, userSig);

  @override
  String toString() {
    return 'IMInfo(appId: $appId, userId: $userId, userSig: $userSig)';
  }
}

/// @nodoc
abstract mixin class $IMInfoCopyWith<$Res> {
  factory $IMInfoCopyWith(IMInfo value, $Res Function(IMInfo) _then) =
      _$IMInfoCopyWithImpl;
  @useResult
  $Res call({String appId, String userId, String userSig});
}

/// @nodoc
class _$IMInfoCopyWithImpl<$Res> implements $IMInfoCopyWith<$Res> {
  _$IMInfoCopyWithImpl(this._self, this._then);

  final IMInfo _self;
  final $Res Function(IMInfo) _then;

  /// Create a copy of IMInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appId = null,
    Object? userId = null,
    Object? userSig = null,
  }) {
    return _then(_self.copyWith(
      appId: null == appId
          ? _self.appId
          : appId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userSig: null == userSig
          ? _self.userSig
          : userSig // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _IMInfo implements IMInfo {
  const _IMInfo(
      {required this.appId, required this.userId, required this.userSig});
  factory _IMInfo.fromJson(Map<String, dynamic> json) => _$IMInfoFromJson(json);

  @override
  final String appId;
  @override
  final String userId;
  @override
  final String userSig;

  /// Create a copy of IMInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$IMInfoCopyWith<_IMInfo> get copyWith =>
      __$IMInfoCopyWithImpl<_IMInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$IMInfoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _IMInfo &&
            (identical(other.appId, appId) || other.appId == appId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userSig, userSig) || other.userSig == userSig));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, appId, userId, userSig);

  @override
  String toString() {
    return 'IMInfo(appId: $appId, userId: $userId, userSig: $userSig)';
  }
}

/// @nodoc
abstract mixin class _$IMInfoCopyWith<$Res> implements $IMInfoCopyWith<$Res> {
  factory _$IMInfoCopyWith(_IMInfo value, $Res Function(_IMInfo) _then) =
      __$IMInfoCopyWithImpl;
  @override
  @useResult
  $Res call({String appId, String userId, String userSig});
}

/// @nodoc
class __$IMInfoCopyWithImpl<$Res> implements _$IMInfoCopyWith<$Res> {
  __$IMInfoCopyWithImpl(this._self, this._then);

  final _IMInfo _self;
  final $Res Function(_IMInfo) _then;

  /// Create a copy of IMInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? appId = null,
    Object? userId = null,
    Object? userSig = null,
  }) {
    return _then(_IMInfo(
      appId: null == appId
          ? _self.appId
          : appId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userSig: null == userSig
          ? _self.userSig
          : userSig // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$VoiceCallInfo {
  String get key;

  /// Create a copy of VoiceCallInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VoiceCallInfoCopyWith<VoiceCallInfo> get copyWith =>
      _$VoiceCallInfoCopyWithImpl<VoiceCallInfo>(
          this as VoiceCallInfo, _$identity);

  /// Serializes this VoiceCallInfo to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VoiceCallInfo &&
            (identical(other.key, key) || other.key == key));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, key);

  @override
  String toString() {
    return 'VoiceCallInfo(key: $key)';
  }
}

/// @nodoc
abstract mixin class $VoiceCallInfoCopyWith<$Res> {
  factory $VoiceCallInfoCopyWith(
          VoiceCallInfo value, $Res Function(VoiceCallInfo) _then) =
      _$VoiceCallInfoCopyWithImpl;
  @useResult
  $Res call({String key});
}

/// @nodoc
class _$VoiceCallInfoCopyWithImpl<$Res>
    implements $VoiceCallInfoCopyWith<$Res> {
  _$VoiceCallInfoCopyWithImpl(this._self, this._then);

  final VoiceCallInfo _self;
  final $Res Function(VoiceCallInfo) _then;

  /// Create a copy of VoiceCallInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
  }) {
    return _then(_self.copyWith(
      key: null == key
          ? _self.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _VoiceCallInfo implements VoiceCallInfo {
  const _VoiceCallInfo({required this.key});
  factory _VoiceCallInfo.fromJson(Map<String, dynamic> json) =>
      _$VoiceCallInfoFromJson(json);

  @override
  final String key;

  /// Create a copy of VoiceCallInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$VoiceCallInfoCopyWith<_VoiceCallInfo> get copyWith =>
      __$VoiceCallInfoCopyWithImpl<_VoiceCallInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$VoiceCallInfoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _VoiceCallInfo &&
            (identical(other.key, key) || other.key == key));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, key);

  @override
  String toString() {
    return 'VoiceCallInfo(key: $key)';
  }
}

/// @nodoc
abstract mixin class _$VoiceCallInfoCopyWith<$Res>
    implements $VoiceCallInfoCopyWith<$Res> {
  factory _$VoiceCallInfoCopyWith(
          _VoiceCallInfo value, $Res Function(_VoiceCallInfo) _then) =
      __$VoiceCallInfoCopyWithImpl;
  @override
  @useResult
  $Res call({String key});
}

/// @nodoc
class __$VoiceCallInfoCopyWithImpl<$Res>
    implements _$VoiceCallInfoCopyWith<$Res> {
  __$VoiceCallInfoCopyWithImpl(this._self, this._then);

  final _VoiceCallInfo _self;
  final $Res Function(_VoiceCallInfo) _then;

  /// Create a copy of VoiceCallInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? key = null,
  }) {
    return _then(_VoiceCallInfo(
      key: null == key
          ? _self.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$BilibiliInfo {
  String get sess;
  String get mixinKey;

  /// Create a copy of BilibiliInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BilibiliInfoCopyWith<BilibiliInfo> get copyWith =>
      _$BilibiliInfoCopyWithImpl<BilibiliInfo>(
          this as BilibiliInfo, _$identity);

  /// Serializes this BilibiliInfo to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BilibiliInfo &&
            (identical(other.sess, sess) || other.sess == sess) &&
            (identical(other.mixinKey, mixinKey) ||
                other.mixinKey == mixinKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, sess, mixinKey);

  @override
  String toString() {
    return 'BilibiliInfo(sess: $sess, mixinKey: $mixinKey)';
  }
}

/// @nodoc
abstract mixin class $BilibiliInfoCopyWith<$Res> {
  factory $BilibiliInfoCopyWith(
          BilibiliInfo value, $Res Function(BilibiliInfo) _then) =
      _$BilibiliInfoCopyWithImpl;
  @useResult
  $Res call({String sess, String mixinKey});
}

/// @nodoc
class _$BilibiliInfoCopyWithImpl<$Res> implements $BilibiliInfoCopyWith<$Res> {
  _$BilibiliInfoCopyWithImpl(this._self, this._then);

  final BilibiliInfo _self;
  final $Res Function(BilibiliInfo) _then;

  /// Create a copy of BilibiliInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sess = null,
    Object? mixinKey = null,
  }) {
    return _then(_self.copyWith(
      sess: null == sess
          ? _self.sess
          : sess // ignore: cast_nullable_to_non_nullable
              as String,
      mixinKey: null == mixinKey
          ? _self.mixinKey
          : mixinKey // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _BilibiliInfo implements BilibiliInfo {
  const _BilibiliInfo({required this.sess, required this.mixinKey});
  factory _BilibiliInfo.fromJson(Map<String, dynamic> json) =>
      _$BilibiliInfoFromJson(json);

  @override
  final String sess;
  @override
  final String mixinKey;

  /// Create a copy of BilibiliInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BilibiliInfoCopyWith<_BilibiliInfo> get copyWith =>
      __$BilibiliInfoCopyWithImpl<_BilibiliInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$BilibiliInfoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BilibiliInfo &&
            (identical(other.sess, sess) || other.sess == sess) &&
            (identical(other.mixinKey, mixinKey) ||
                other.mixinKey == mixinKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, sess, mixinKey);

  @override
  String toString() {
    return 'BilibiliInfo(sess: $sess, mixinKey: $mixinKey)';
  }
}

/// @nodoc
abstract mixin class _$BilibiliInfoCopyWith<$Res>
    implements $BilibiliInfoCopyWith<$Res> {
  factory _$BilibiliInfoCopyWith(
          _BilibiliInfo value, $Res Function(_BilibiliInfo) _then) =
      __$BilibiliInfoCopyWithImpl;
  @override
  @useResult
  $Res call({String sess, String mixinKey});
}

/// @nodoc
class __$BilibiliInfoCopyWithImpl<$Res>
    implements _$BilibiliInfoCopyWith<$Res> {
  __$BilibiliInfoCopyWithImpl(this._self, this._then);

  final _BilibiliInfo _self;
  final $Res Function(_BilibiliInfo) _then;

  /// Create a copy of BilibiliInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? sess = null,
    Object? mixinKey = null,
  }) {
    return _then(_BilibiliInfo(
      sess: null == sess
          ? _self.sess
          : sess // ignore: cast_nullable_to_non_nullable
              as String,
      mixinKey: null == mixinKey
          ? _self.mixinKey
          : mixinKey // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$AListInfo {
  String get host;
  String get token;

  /// Create a copy of AListInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AListInfoCopyWith<AListInfo> get copyWith =>
      _$AListInfoCopyWithImpl<AListInfo>(this as AListInfo, _$identity);

  /// Serializes this AListInfo to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AListInfo &&
            (identical(other.host, host) || other.host == host) &&
            (identical(other.token, token) || other.token == token));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, host, token);

  @override
  String toString() {
    return 'AListInfo(host: $host, token: $token)';
  }
}

/// @nodoc
abstract mixin class $AListInfoCopyWith<$Res> {
  factory $AListInfoCopyWith(AListInfo value, $Res Function(AListInfo) _then) =
      _$AListInfoCopyWithImpl;
  @useResult
  $Res call({String host, String token});
}

/// @nodoc
class _$AListInfoCopyWithImpl<$Res> implements $AListInfoCopyWith<$Res> {
  _$AListInfoCopyWithImpl(this._self, this._then);

  final AListInfo _self;
  final $Res Function(AListInfo) _then;

  /// Create a copy of AListInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? host = null,
    Object? token = null,
  }) {
    return _then(_self.copyWith(
      host: null == host
          ? _self.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _self.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _AListInfo implements AListInfo {
  const _AListInfo({required this.host, required this.token});
  factory _AListInfo.fromJson(Map<String, dynamic> json) =>
      _$AListInfoFromJson(json);

  @override
  final String host;
  @override
  final String token;

  /// Create a copy of AListInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AListInfoCopyWith<_AListInfo> get copyWith =>
      __$AListInfoCopyWithImpl<_AListInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AListInfoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AListInfo &&
            (identical(other.host, host) || other.host == host) &&
            (identical(other.token, token) || other.token == token));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, host, token);

  @override
  String toString() {
    return 'AListInfo(host: $host, token: $token)';
  }
}

/// @nodoc
abstract mixin class _$AListInfoCopyWith<$Res>
    implements $AListInfoCopyWith<$Res> {
  factory _$AListInfoCopyWith(
          _AListInfo value, $Res Function(_AListInfo) _then) =
      __$AListInfoCopyWithImpl;
  @override
  @useResult
  $Res call({String host, String token});
}

/// @nodoc
class __$AListInfoCopyWithImpl<$Res> implements _$AListInfoCopyWith<$Res> {
  __$AListInfoCopyWithImpl(this._self, this._then);

  final _AListInfo _self;
  final $Res Function(_AListInfo) _then;

  /// Create a copy of AListInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? host = null,
    Object? token = null,
  }) {
    return _then(_AListInfo(
      host: null == host
          ? _self.host
          : host // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _self.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$ChannelInfo {
  String get id;
  String get name;

  /// Create a copy of ChannelInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChannelInfoCopyWith<ChannelInfo> get copyWith =>
      _$ChannelInfoCopyWithImpl<ChannelInfo>(this as ChannelInfo, _$identity);

  /// Serializes this ChannelInfo to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChannelInfo &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @override
  String toString() {
    return 'ChannelInfo(id: $id, name: $name)';
  }
}

/// @nodoc
abstract mixin class $ChannelInfoCopyWith<$Res> {
  factory $ChannelInfoCopyWith(
          ChannelInfo value, $Res Function(ChannelInfo) _then) =
      _$ChannelInfoCopyWithImpl;
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class _$ChannelInfoCopyWithImpl<$Res> implements $ChannelInfoCopyWith<$Res> {
  _$ChannelInfoCopyWithImpl(this._self, this._then);

  final ChannelInfo _self;
  final $Res Function(ChannelInfo) _then;

  /// Create a copy of ChannelInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ChannelInfo implements ChannelInfo {
  const _ChannelInfo({required this.id, required this.name});
  factory _ChannelInfo.fromJson(Map<String, dynamic> json) =>
      _$ChannelInfoFromJson(json);

  @override
  final String id;
  @override
  final String name;

  /// Create a copy of ChannelInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChannelInfoCopyWith<_ChannelInfo> get copyWith =>
      __$ChannelInfoCopyWithImpl<_ChannelInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChannelInfoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChannelInfo &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @override
  String toString() {
    return 'ChannelInfo(id: $id, name: $name)';
  }
}

/// @nodoc
abstract mixin class _$ChannelInfoCopyWith<$Res>
    implements $ChannelInfoCopyWith<$Res> {
  factory _$ChannelInfoCopyWith(
          _ChannelInfo value, $Res Function(_ChannelInfo) _then) =
      __$ChannelInfoCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String name});
}

/// @nodoc
class __$ChannelInfoCopyWithImpl<$Res> implements _$ChannelInfoCopyWith<$Res> {
  __$ChannelInfoCopyWithImpl(this._self, this._then);

  final _ChannelInfo _self;
  final $Res Function(_ChannelInfo) _then;

  /// Create a copy of ChannelInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_ChannelInfo(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$BungaClientInfo {
  String get token;
  ChannelInfo get channel;
  IMInfo get im;
  VoiceCallInfo? get voiceCall;
  BilibiliInfo? get bilibili;
  AListInfo? get alist;

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BungaClientInfoCopyWith<BungaClientInfo> get copyWith =>
      _$BungaClientInfoCopyWithImpl<BungaClientInfo>(
          this as BungaClientInfo, _$identity);

  /// Serializes this BungaClientInfo to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BungaClientInfo &&
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

  @override
  String toString() {
    return 'BungaClientInfo(token: $token, channel: $channel, im: $im, voiceCall: $voiceCall, bilibili: $bilibili, alist: $alist)';
  }
}

/// @nodoc
abstract mixin class $BungaClientInfoCopyWith<$Res> {
  factory $BungaClientInfoCopyWith(
          BungaClientInfo value, $Res Function(BungaClientInfo) _then) =
      _$BungaClientInfoCopyWithImpl;
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
class _$BungaClientInfoCopyWithImpl<$Res>
    implements $BungaClientInfoCopyWith<$Res> {
  _$BungaClientInfoCopyWithImpl(this._self, this._then);

  final BungaClientInfo _self;
  final $Res Function(BungaClientInfo) _then;

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
    return _then(_self.copyWith(
      token: null == token
          ? _self.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      channel: null == channel
          ? _self.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as ChannelInfo,
      im: null == im
          ? _self.im
          : im // ignore: cast_nullable_to_non_nullable
              as IMInfo,
      voiceCall: freezed == voiceCall
          ? _self.voiceCall
          : voiceCall // ignore: cast_nullable_to_non_nullable
              as VoiceCallInfo?,
      bilibili: freezed == bilibili
          ? _self.bilibili
          : bilibili // ignore: cast_nullable_to_non_nullable
              as BilibiliInfo?,
      alist: freezed == alist
          ? _self.alist
          : alist // ignore: cast_nullable_to_non_nullable
              as AListInfo?,
    ));
  }

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChannelInfoCopyWith<$Res> get channel {
    return $ChannelInfoCopyWith<$Res>(_self.channel, (value) {
      return _then(_self.copyWith(channel: value));
    });
  }

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IMInfoCopyWith<$Res> get im {
    return $IMInfoCopyWith<$Res>(_self.im, (value) {
      return _then(_self.copyWith(im: value));
    });
  }

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VoiceCallInfoCopyWith<$Res>? get voiceCall {
    if (_self.voiceCall == null) {
      return null;
    }

    return $VoiceCallInfoCopyWith<$Res>(_self.voiceCall!, (value) {
      return _then(_self.copyWith(voiceCall: value));
    });
  }

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BilibiliInfoCopyWith<$Res>? get bilibili {
    if (_self.bilibili == null) {
      return null;
    }

    return $BilibiliInfoCopyWith<$Res>(_self.bilibili!, (value) {
      return _then(_self.copyWith(bilibili: value));
    });
  }

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AListInfoCopyWith<$Res>? get alist {
    if (_self.alist == null) {
      return null;
    }

    return $AListInfoCopyWith<$Res>(_self.alist!, (value) {
      return _then(_self.copyWith(alist: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _BungaClientInfo implements BungaClientInfo {
  const _BungaClientInfo(
      {required this.token,
      required this.channel,
      required this.im,
      this.voiceCall,
      this.bilibili,
      this.alist});
  factory _BungaClientInfo.fromJson(Map<String, dynamic> json) =>
      _$BungaClientInfoFromJson(json);

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

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BungaClientInfoCopyWith<_BungaClientInfo> get copyWith =>
      __$BungaClientInfoCopyWithImpl<_BungaClientInfo>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$BungaClientInfoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BungaClientInfo &&
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

  @override
  String toString() {
    return 'BungaClientInfo(token: $token, channel: $channel, im: $im, voiceCall: $voiceCall, bilibili: $bilibili, alist: $alist)';
  }
}

/// @nodoc
abstract mixin class _$BungaClientInfoCopyWith<$Res>
    implements $BungaClientInfoCopyWith<$Res> {
  factory _$BungaClientInfoCopyWith(
          _BungaClientInfo value, $Res Function(_BungaClientInfo) _then) =
      __$BungaClientInfoCopyWithImpl;
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
class __$BungaClientInfoCopyWithImpl<$Res>
    implements _$BungaClientInfoCopyWith<$Res> {
  __$BungaClientInfoCopyWithImpl(this._self, this._then);

  final _BungaClientInfo _self;
  final $Res Function(_BungaClientInfo) _then;

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? token = null,
    Object? channel = null,
    Object? im = null,
    Object? voiceCall = freezed,
    Object? bilibili = freezed,
    Object? alist = freezed,
  }) {
    return _then(_BungaClientInfo(
      token: null == token
          ? _self.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      channel: null == channel
          ? _self.channel
          : channel // ignore: cast_nullable_to_non_nullable
              as ChannelInfo,
      im: null == im
          ? _self.im
          : im // ignore: cast_nullable_to_non_nullable
              as IMInfo,
      voiceCall: freezed == voiceCall
          ? _self.voiceCall
          : voiceCall // ignore: cast_nullable_to_non_nullable
              as VoiceCallInfo?,
      bilibili: freezed == bilibili
          ? _self.bilibili
          : bilibili // ignore: cast_nullable_to_non_nullable
              as BilibiliInfo?,
      alist: freezed == alist
          ? _self.alist
          : alist // ignore: cast_nullable_to_non_nullable
              as AListInfo?,
    ));
  }

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChannelInfoCopyWith<$Res> get channel {
    return $ChannelInfoCopyWith<$Res>(_self.channel, (value) {
      return _then(_self.copyWith(channel: value));
    });
  }

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $IMInfoCopyWith<$Res> get im {
    return $IMInfoCopyWith<$Res>(_self.im, (value) {
      return _then(_self.copyWith(im: value));
    });
  }

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VoiceCallInfoCopyWith<$Res>? get voiceCall {
    if (_self.voiceCall == null) {
      return null;
    }

    return $VoiceCallInfoCopyWith<$Res>(_self.voiceCall!, (value) {
      return _then(_self.copyWith(voiceCall: value));
    });
  }

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BilibiliInfoCopyWith<$Res>? get bilibili {
    if (_self.bilibili == null) {
      return null;
    }

    return $BilibiliInfoCopyWith<$Res>(_self.bilibili!, (value) {
      return _then(_self.copyWith(bilibili: value));
    });
  }

  /// Create a copy of BungaClientInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AListInfoCopyWith<$Res>? get alist {
    if (_self.alist == null) {
      return null;
    }

    return $AListInfoCopyWith<$Res>(_self.alist!, (value) {
      return _then(_self.copyWith(alist: value));
    });
  }
}

// dart format on
