import 'dart:ui';

import 'package:bunga_player/chat/actions.dart';
import 'package:bunga_player/popmoji/constants.dart';
import 'package:bunga_player/popmoji/models.dart';
import 'package:bunga_player/screens/widgets/scroll_optimizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bunga_player/mocks/tooltip.dart' as mock;
import 'package:lottie/lottie.dart';
import 'package:nested/nested.dart';

class PopmojiControl extends StatefulWidget {
  static Future<void> cacheSvgs() async {
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

      final icon = SvgAssetLoader(_assetPathByCode(code));
      await svg.cache
          .putIfAbsent(icon.cacheKey(null), () => icon.loadBytes(null));
    }
  }

  const PopmojiControl({super.key});

  @override
  State<PopmojiControl> createState() => _PopmojiControlState();
}

class _PopmojiControlState extends State<PopmojiControl> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

      emojiButtons.add(_EmojiButton(code: code));
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
          child: ScrollOptimizer(
            scrollController: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(children: [...emojiButtons]),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _EmojiButton extends StatelessWidget {
  final String code;

  const _EmojiButton({required this.code});

  @override
  Widget build(BuildContext context) {
    final svg = SvgPicture.asset(
      _assetPathByCode(code),
      height: 24,
    );

    final button = IconButton(
      icon: svg,
      onPressed: () {
        // send popmoji
        Actions.invoke(
          context,
          SendMessageIntent(PopmojiMessageData(code: code).toMessageData()),
        );
        _showThrowEmojiAnimation(context);
        Navigator.of(context).pop();
      },
    );

    return mock.Tooltip(
      decoration: BoxDecoration(
        color: Theme.of(context).shadowColor.withOpacity(0.7),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      richMessage: WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Lottie.asset(
            'assets/images/emojis/u$code.json',
            repeat: true,
            height: 64,
          ),
        ),
      ),
      rootOverlay: true,
      child: button,
    );
  }

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
          child: SvgPicture.asset('assets/images/emojis/u$code.svg'),
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(overlayEntry);
  }
}

class _ThrowAnimation extends SingleChildStatefulWidget {
  final Rect startRect, endRect;
  final OverlayEntry overlay;
  const _ThrowAnimation({
    required this.startRect,
    required this.endRect,
    required this.overlay,
    super.child,
  });
  @override
  State<_ThrowAnimation> createState() => _ThrowAnimationState();
}

class _ThrowAnimationState extends SingleChildState<_ThrowAnimation>
    with SingleTickerProviderStateMixin {
  late final _path = Path()
    ..moveTo(widget.startRect.left, widget.startRect.top)
    ..quadraticBezierTo(
      widget.startRect.left,
      widget.endRect.top,
      widget.endRect.left,
      widget.endRect.top,
    );
  late var _position = Offset(
    widget.startRect.left,
    widget.startRect.top,
  );
  late final _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000));
  late final _positionTween = Tween(begin: 0.0, end: 1.0)
      .chain(CurveTween(curve: Curves.easeOutCubic))
      .animate(_controller);
  late final _sizeTween = TweenSequence<double>(
    [
      TweenSequenceItem(
        weight: 1.0,
        tween: Tween(begin: 0, end: -1),
      ),
      TweenSequenceItem(
        weight: 1.6,
        tween: Tween(begin: -1, end: 1),
      ),
    ],
  ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_controller);

  @override
  void initState() {
    super.initState();

    _positionTween.addListener(() {
      setState(() {
        _calcPosition(_positionTween.value);
      });
    });
    _controller.forward().then((_) => widget.overlay.remove());
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    final rect = Rect.lerp(widget.startRect, widget.endRect, _sizeTween.value)!;
    return Stack(
      children: [
        Positioned(
          left: _position.dx,
          top: _position.dy,
          width: rect.width,
          height: rect.height,
          child: child!,
        ),
      ],
    );
  }

  void _calcPosition(double tween) {
    PathMetrics pathMetrics = _path.computeMetrics();
    PathMetric pathMetric = pathMetrics.elementAt(0);
    tween = pathMetric.length * tween;
    _position = pathMetric.getTangentForOffset(tween)!.position;
  }
}

String _assetPathByCode(String code) => 'assets/images/emojis/u$code.svg';
