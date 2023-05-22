double dToS(Duration duration) {
  return duration.inMilliseconds / 1000.0;
}

Duration sToD(double seconds) {
  return Duration(milliseconds: (seconds * 1000).toInt());
}

String dToHHmmss(Duration d) {
  return d.toString().split('.').first.padLeft(8, "0");
}
