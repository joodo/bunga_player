import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:flutter/material.dart';

class LoadingText extends StatelessWidget {
  final String text;

  const LoadingText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text).breath();
  }
}
