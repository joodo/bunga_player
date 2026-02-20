import 'package:freezed_annotation/freezed_annotation.dart';

part 'volume.freezed.dart';

@freezed
abstract class Volume with _$Volume {
  static const Volume max = Volume.raw(level: 1.0, mute: false);

  const Volume._();

  const factory Volume.raw({required double level, required bool mute}) =
      _Volume;

  factory Volume({required double level, bool mute = false}) {
    return Volume.raw(level: level.clamp(0.0, 1.0), mute: mute);
  }
}
