class Volume {
  static const int max = 100;
  static const int min = 0;

  Volume({required int volume, this.mute = false})
      : volume = volume.clamp(min, max);

  final int volume;
  final bool mute;

  double get percent => volume / (max - min);

  Volume copyWithToggleMute() => Volume(volume: volume, mute: !mute);
}
