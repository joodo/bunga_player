import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:styled_widget/styled_widget.dart';

class WaitWidget extends StatelessWidget {
  const WaitWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return [
      Lottie.asset(
        'assets/images/watch_movie.zip',
      ),
      const Text('正在等待其他人放映……')
          .textStyle(Theme.of(context).textTheme.headlineLarge!)
          .breath()
          .padding(top: 24.0, bottom: 48.0),
    ].toColumn().fittedBox().padding(vertical: 24.0).center();
  }
}
