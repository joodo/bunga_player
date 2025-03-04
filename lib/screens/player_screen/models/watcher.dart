import 'package:bunga_player/chat/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'watcher.freezed.dart';

@freezed
abstract class Watcher with _$Watcher {
  const factory Watcher({
    required User user,
    required bool isTalking,
  }) = _Watcher;
}
