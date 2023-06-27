import 'package:bunga_player/singletons/popmoji_controller.dart';
import 'package:bunga_player/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PopmojiControl extends StatelessWidget {
  const PopmojiControl({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> emojiButtons = [];
    String? previousCode;
    for (var rune in Popmoji.emojis.runes) {
      var code = rune.toRadixString(16);
      if (code.length < 5) {
        if (previousCode == null) {
          previousCode = code;
        } else {
          code = '${previousCode}_$code';
          final svg = SvgPicture.asset(
            'assets/images/emojis/u$previousCode.svg',
            height: 24,
          );
          previousCode = null;

          emojiButtons.add(IconButton(
            icon: svg,
            onPressed: () {
              PopmojiController().send(code);
            },
          ));
        }
        continue;
      }

      final svg = SvgPicture.asset(
        'assets/images/emojis/u$code.svg',
        height: 24,
      );
      emojiButtons.add(IconButton(
        icon: svg,
        onPressed: () {
          PopmojiController().send(code);
          Navigator.of(context).pop();
        },
      ));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8),
        // Back button
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Navigator.of(context).pop,
        ),
        const SizedBox(width: 8),

        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [...emojiButtons]),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
