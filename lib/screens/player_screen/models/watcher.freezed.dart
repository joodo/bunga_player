// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'watcher.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Watcher {
  User get user;
  bool get isTalking;

  /// Create a copy of Watcher
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WatcherCopyWith<Watcher> get copyWith =>
      _$WatcherCopyWithImpl<Watcher>(this as Watcher, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Watcher &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.isTalking, isTalking) ||
                other.isTalking == isTalking));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user, isTalking);

  @override
  String toString() {
    return 'Watcher(user: $user, isTalking: $isTalking)';
  }
}

/// @nodoc
abstract mixin class $WatcherCopyWith<$Res> {
  factory $WatcherCopyWith(Watcher value, $Res Function(Watcher) _then) =
      _$WatcherCopyWithImpl;
  @useResult
  $Res call({User user, bool isTalking});
}

/// @nodoc
class _$WatcherCopyWithImpl<$Res> implements $WatcherCopyWith<$Res> {
  _$WatcherCopyWithImpl(this._self, this._then);

  final Watcher _self;
  final $Res Function(Watcher) _then;

  /// Create a copy of Watcher
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? isTalking = null,
  }) {
    return _then(_self.copyWith(
      user: null == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      isTalking: null == isTalking
          ? _self.isTalking
          : isTalking // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _Watcher implements Watcher {
  const _Watcher({required this.user, required this.isTalking});

  @override
  final User user;
  @override
  final bool isTalking;

  /// Create a copy of Watcher
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WatcherCopyWith<_Watcher> get copyWith =>
      __$WatcherCopyWithImpl<_Watcher>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Watcher &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.isTalking, isTalking) ||
                other.isTalking == isTalking));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user, isTalking);

  @override
  String toString() {
    return 'Watcher(user: $user, isTalking: $isTalking)';
  }
}

/// @nodoc
abstract mixin class _$WatcherCopyWith<$Res> implements $WatcherCopyWith<$Res> {
  factory _$WatcherCopyWith(_Watcher value, $Res Function(_Watcher) _then) =
      __$WatcherCopyWithImpl;
  @override
  @useResult
  $Res call({User user, bool isTalking});
}

/// @nodoc
class __$WatcherCopyWithImpl<$Res> implements _$WatcherCopyWith<$Res> {
  __$WatcherCopyWithImpl(this._self, this._then);

  final _Watcher _self;
  final $Res Function(_Watcher) _then;

  /// Create a copy of Watcher
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? user = null,
    Object? isTalking = null,
  }) {
    return _then(_Watcher(
      user: null == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      isTalking: null == isTalking
          ? _self.isTalking
          : isTalking // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
