import 'package:bunga_player/actions/popmoji.dart';
import 'package:bunga_player/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PopmojiControl extends StatelessWidget {
  const PopmojiControl({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> emojiButtons = [];
    String? previousCode;
    for (var rune in emojis.runes) {
      var code = rune.toRadixString(16);
      if (code.length < 5) {
        if (previousCode == null) {
          previousCode = code;
          continue;
        } else {
          code = '${previousCode}_$code';
          previousCode = null;
        }
      }

      final svg = SvgPicture.asset(
        'assets/images/emojis/u$code.svg',
        height: 24,
      );
      emojiButtons.add(IconButton(
        icon: svg,
        onPressed: () {
          sendPopmoji(code);
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
