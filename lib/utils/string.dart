extension URL on String {
  Uri parseUri() {
    final regex = RegExp(
        r'(http|https):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])');
    final url = regex.firstMatch(this)?.group(0);
    if (url == null) throw const FormatException('Illegal url');

    return Uri.parse(url);
  }
}
