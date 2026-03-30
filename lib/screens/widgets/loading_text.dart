import 'package:flutter/material.dart';

import '/utils/utils.dart';

class LoadingText extends StatelessWidget {
  final String text;

  const LoadingText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text).breath();
  }
}
