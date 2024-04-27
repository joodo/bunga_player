import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

TextSpan createHyperText(BuildContext context,
    {required String text, required String url}) {
  return TextSpan(
    text: text,
    style: TextStyle(color: Theme.of(context).colorScheme.primary),
    recognizer: TapGestureRecognizer()..onTap = () => launchUrlString(url),
  );
}
