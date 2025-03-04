// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClientAccount {
  @JsonKey(name: "username")
  String get id;
  String get password;

  /// Create a copy of ClientAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ClientAccountCopyWith<ClientAccount> get copyWith =>
      _$ClientAccountCopyWithImpl<ClientAccount>(
          this as ClientAccount, _$identity);

  /// Serializes this ClientAccount to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ClientAccount &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, password);

  @override
  String toString() {
    return 'ClientAccount(id: $id, password: $password)';
  }
}

/// @nodoc
abstract mixin class $ClientAccountCopyWith<$Res> {
  factory $ClientAccountCopyWith(
          ClientAccount value, $Res Function(ClientAccount) _then) =
      _$ClientAccountCopyWithImpl;
  @useResult
  $Res call({@JsonKey(name: "username") String id, String password});
}

/// @nodoc
class _$ClientAccountCopyWithImpl<$Res>
    implements $ClientAccountCopyWith<$Res> {
  _$ClientAccountCopyWithImpl(this._self, this._then);

  final ClientAccount _self;
  final $Res Function(ClientAccount) _then;

  /// Create a copy of ClientAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? password = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _ClientAccount implements ClientAccount {
  const _ClientAccount(
      {@JsonKey(name: "username") required this.id, required this.password});
  factory _ClientAccount.fromJson(Map<String, dynamic> json) =>
      _$ClientAccountFromJson(json);

  @override
  @JsonKey(name: "username")
  final String id;
  @override
  final String password;

  /// Create a copy of ClientAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ClientAccountCopyWith<_ClientAccount> get copyWith =>
      __$ClientAccountCopyWithImpl<_ClientAccount>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ClientAccountToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ClientAccount &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, password);

  @override
  String toString() {
    return 'ClientAccount(id: $id, password: $password)';
  }
}

/// @nodoc
abstract mixin class _$ClientAccountCopyWith<$Res>
    implements $ClientAccountCopyWith<$Res> {
  factory _$ClientAccountCopyWith(
          _ClientAccount value, $Res Function(_ClientAccount) _then) =
      __$ClientAccountCopyWithImpl;
  @override
  @useResult
  $Res call({@JsonKey(name: "username") String id, String password});
}

/// @nodoc
class __$ClientAccountCopyWithImpl<$Res>
    implements _$ClientAccountCopyWith<$Res> {
  __$ClientAccountCopyWithImpl(this._self, this._then);

  final _ClientAccount _self;
  final $Res Function(_ClientAccount) _then;

  /// Create a copy of ClientAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? password = null,
  }) {
    return _then(_ClientAccount(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _self.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
