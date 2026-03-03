import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/reaction/business.dart';
import 'package:bunga_player/reaction/models/emoji_data.dart';
import 'package:bunga_player/screens/widgets/widgets.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/utils/extensions/extensions.dart';

import 'blur_chip.dart';

class SparkSelectionBar extends StatefulWidget {
  const SparkSelectionBar({super.key});

  @override
  State<SparkSelectionBar> createState() => _SparkSelectionBarState();
}

class _SparkSelectionBarState extends State<SparkSelectionBar> {
  final _visibleNotifier = AutoResetNotifier(const Duration(seconds: 2));
  late final _startEvent = context.read<SparkingStartEvent>();

  @override
  void initState() {
    super.initState();

    _startEvent.addListener(_show);
    _cacheEmoji();
  }

  @override
  void dispose() {
    _startEvent.removeListener(_show);
    _visibleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentNotifier = context.read<SparkingEmojiNotifier>();

    const horiPadding = 12.0;
    const buttonWidth = 48.0, buttonHeight = 54.0;

    final background = ValueListenableBuilder(
      valueListenable: currentNotifier,
      builder: (context, currentEmoji, child) {
        final currentIndex = sparkOptions.indexWhere((e) => e == currentEmoji);
        return [
              if (currentIndex >= 0)
                Container(color: Colors.white30)
                    .clipRRect(all: buttonWidth)
                    .positioned(
                      width: buttonWidth,
                      left: horiPadding + currentIndex * buttonWidth,
                      top: 0,
                      bottom: 0,
                      animate: true,
                    ),
            ]
            .toStack()
            .animate(
              const Duration(milliseconds: 200),
              Curves.easeInOutCubicEmphasized,
            )
            .constrained(
              width: 2 * horiPadding + sparkOptions.length * buttonWidth,
              height: buttonHeight,
            );
      },
    );

    final buttons = sparkOptions
        .map(
          (e) => IconButton(
            icon: _cachedImage[e] ?? const SizedBox.shrink(),
            onPressed: () => currentNotifier.value = e,
          ).constrained(width: buttonWidth, height: buttonHeight),
        )
        .toList()
        .toRow(mainAxisSize: .min)
        .padding(horizontal: horiPadding);

    final mouseRegion =
        MouseRegion(
          opaque: false,
          onEnter: (event) => _visibleNotifier.lockUp('mouse enter'),
          onExit: (event) {
            _visibleNotifier.unlock('mouse enter');
            _visibleNotifier.mark();
          },
        ).constrained(
          width: 2 * horiPadding + sparkOptions.length * buttonWidth,
          height: buttonHeight,
        );

    final content = [background, buttons, mouseRegion].toStack().blurChip();

    final link = LayerLink();
    return ValueListenableBuilder(
      valueListenable: _visibleNotifier,
      builder: (context, visible, child) {
        return PopupWidget(
          showing: visible,
          layoutBuilder: (context, popup) => UnconstrainedBox(
            child: CompositedTransformFollower(
              link: link,
              targetAnchor: .bottomRight,
              followerAnchor: .bottomRight,
              offset: Offset(-16.0, -16.0),
              child: popup,
            ),
          ),
          popupBuilder: (context) => content,

          child: child,
        );
      },
      child: CompositedTransformTarget(
        link: link,
        child: const SizedBox.expand(),
      ),
    );
  }

  void _show() => _visibleNotifier.mark();

  static final _cachedImage = <String, RawImage>{};
  Future<void> _cacheEmoji() async {
    if (_cachedImage.isNotEmpty) return;

    const size = 32.0;
    for (final emoji in sparkOptions) {
      _cachedImage[emoji] = RawImage(
        image: await EmojiData.createImage(emoji, size),
      );
    }
    setState(() {});
  }
}
