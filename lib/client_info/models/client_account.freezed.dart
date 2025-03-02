// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'client_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ClientAccount _$ClientAccountFromJson(Map<String, dynamic> json) {
  return _ClientAccount.fromJson(json);
}

/// @nodoc
mixin _$ClientAccount {
  @JsonKey(name: "username")
  String get id => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  /// Serializes this ClientAccount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClientAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClientAccountCopyWith<ClientAccount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClientAccountCopyWith<$Res> {
  factory $ClientAccountCopyWith(
          ClientAccount value, $Res Function(ClientAccount) then) =
      _$ClientAccountCopyWithImpl<$Res, ClientAccount>;
  @useResult
  $Res call({@JsonKey(name: "username") String id, String password});
}

/// @nodoc
class _$ClientAccountCopyWithImpl<$Res, $Val extends ClientAccount>
    implements $ClientAccountCopyWith<$Res> {
  _$ClientAccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClientAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? password = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClientAccountImplCopyWith<$Res>
    implements $ClientAccountCopyWith<$Res> {
  factory _$$ClientAccountImplCopyWith(
          _$ClientAccountImpl value, $Res Function(_$ClientAccountImpl) then) =
      __$$ClientAccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: "username") String id, String password});
}

/// @nodoc
class __$$ClientAccountImplCopyWithImpl<$Res>
    extends _$ClientAccountCopyWithImpl<$Res, _$ClientAccountImpl>
    implements _$$ClientAccountImplCopyWith<$Res> {
  __$$ClientAccountImplCopyWithImpl(
      _$ClientAccountImpl _value, $Res Function(_$ClientAccountImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClientAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? password = null,
  }) {
    return _then(_$ClientAccountImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClientAccountImpl implements _ClientAccount {
  const _$ClientAccountImpl(
      {@JsonKey(name: "username") required this.id, required this.password});

  factory _$ClientAccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClientAccountImplFromJson(json);

  @override
  @JsonKey(name: "username")
  final String id;
  @override
  final String password;

  @override
  String toString() {
    return 'ClientAccount(id: $id, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClientAccountImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, password);

  /// Create a copy of ClientAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClientAccountImplCopyWith<_$ClientAccountImpl> get copyWith =>
      __$$ClientAccountImplCopyWithImpl<_$ClientAccountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClientAccountImplToJson(
      this,
    );
  }
}

abstract class _ClientAccount implements ClientAccount {
  const factory _ClientAccount(
      {@JsonKey(name: "username") required final String id,
      required final String password}) = _$ClientAccountImpl;

  factory _ClientAccount.fromJson(Map<String, dynamic> json) =
      _$ClientAccountImpl.fromJson;

  @override
  @JsonKey(name: "username")
  String get id;
  @override
  String get password;

  /// Create a copy of ClientAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClientAccountImplCopyWith<_$ClientAccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
