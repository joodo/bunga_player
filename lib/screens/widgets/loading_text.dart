import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class LoadingText extends StatelessWidget {
  final String text;

  const LoadingText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text),
        SizedBox(
          width: 20,
          child: AnimatedTextKit(
            animatedTexts: [
              TyperAnimatedText(
                '...',
                speed: const Duration(milliseconds: 500),
              )
            ],
            repeatForever: true,
            pause: const Duration(milliseconds: 500),
          ),
        ),
      ],
    );
  }
}
