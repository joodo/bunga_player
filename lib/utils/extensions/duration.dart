extension FormatString on Duration {
  String get hhmmss => toString().split('.').first.padLeft(8, "0");
}

extension Near on Duration {
  bool near(
    Duration other, {
    Duration tolerance = const Duration(milliseconds: 400),
  }) => (this - other).abs() <= tolerance;
}

extension MoreSpan on Duration {
  int get inMonths => inDays ~/ 30;
  int get inYears => inMonths ~/ 12;
}
