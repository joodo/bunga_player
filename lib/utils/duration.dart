extension FormatString on Duration {
  String get hhmmss => toString().split('.').first.padLeft(8, "0");
}

extension Clamp on Duration {
  Duration clamp(Duration min, Duration max) => this < min
      ? min
      : this > max
          ? max
          : this;
}
