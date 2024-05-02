extension FormatString on Duration {
  String get hhmmss => toString().split('.').first.padLeft(8, "0");
}
