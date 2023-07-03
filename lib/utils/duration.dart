extension FormatString on Duration {
  String get hhmmss => toString().split('.').first.padLeft(8, "0");
}

extension ToDuration on double {
  Duration get asMilliseconds => Duration(milliseconds: toInt());
}
