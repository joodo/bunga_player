import 'package:bunga_player/popmoji/models/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:vector_graphics/vector_graphics.dart';

class PopmojiButton extends StatelessWidget {
  final String emoji;
  final VoidCallback onPressed;
  final Duration? waitDuration;
  final double size;

  const PopmojiButton(
    this.emoji, {
    super.key,
    this.waitDuration,
    required this.onPressed,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size - 16;
    final svg = SvgPicture(
      AssetBytesLoader(EmojiData.svgPath(emoji)),
      width: iconSize,
      height: iconSize,
    );

    final button = IconButton(
      icon: svg,
      onPressed: () {
        //_showThrowEmojiAnimation(context);
        onPressed();
      },
    );

    return Tooltip(
      waitDuration: waitDuration,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).shadowColor.withAlpha(215),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      richMessage: WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Lottie.asset(
                EmojiData.lottiePath(emoji),
                repeat: true,
                height: 64,
              ),
              const SizedBox(height: 4),
              Text(context.read<EmojiData>().tags[emoji]?.first ?? ''),
            ],
          ),
        ),
      ),
      child: button,
    );
  }
/*
  void _showThrowEmojiAnimation(BuildContext context) {
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay = Navigator.of(
      context,
      rootNavigator: true,
    ).overlay!.context.findRenderObject()! as RenderBox;
    final position = Rect.fromPoints(
      button.localToGlobal(Offset.zero, ancestor: overlay),
      button.localToGlobal(button.size.bottomRight(Offset.zero),
          ancestor: overlay),
    );

    late final OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return _ThrowAnimation(
          startRect: position,
          endRect: Rect.fromLTWH(
            overlay.size.width / 2,
            overlay.size.height / 2,
            0,
            0,
          ),
          overlay: overlayEntry,
          child: SvgPicture.asset(EmojiData.svgPath(emoji)),
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(overlayEntry);
  }*/
}
