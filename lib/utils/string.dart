Uri parseUrlFrom(String string) {
  final regex = RegExp(
      r'(http|https):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])');
  final url = regex.firstMatch(string)?.group(0);
  if (url == null) throw const FormatException('Illegal url');

  return Uri.parse(url);
}
