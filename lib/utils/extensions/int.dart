extension FormatBytes on int {
  String get formatBytes {
    if (this < 1024) {
      return '$this B';
    } else if (this < 1048576) {
      double kb = this / 1024;
      return '${kb.toStringAsFixed(2)} KB';
    } else if (this < 1073741824) {
      double mb = this / 1048576;
      return '${mb.toStringAsFixed(2)} MB';
    } else {
      double gb = this / 1073741824;
      return '${gb.toStringAsFixed(2)} GB';
    }
  }
}
