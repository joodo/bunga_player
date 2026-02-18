import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'popmoji.dart';
import 'danmaku.dart';
import 'spark.dart';

class VibeLayer extends StatelessWidget {
  const VibeLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return [
      const PopmojiLayer(),
      const DanmakuLayer(),
      const SparkLayer(),
    ].toStack();
  }
}
