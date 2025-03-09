import 'package:freezed_annotation/freezed_annotation.dart';

part 'volume.freezed.dart';

@freezed
abstract class Volume with _$Volume {
  static const int max = 100;
  static const int min = 0;

  factory Volume({required int volume, @Default(false) bool mute}) = _Volume;
}
