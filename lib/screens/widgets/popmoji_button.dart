import 'dart:ui';

import 'package:bunga_player/danmaku/models/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:vector_graphics/vector_graphics.dart';

// TODO: move file

class PopmojiButton extends StatelessWidget {
  final String emoji;
  final VoidCallback? onPressed;
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
        _showThrowEmojiAnimation(context);
        onPressed?.call();
      },
    );

    return Tooltip(
      waitDuration: waitDuration,
      margin: const EdgeInsets.all(8),
      preferBelow: false,
      decoration: BoxDecoration(
        color: Theme.of(context).shadowColor.withAlpha(215),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      richMessage: WidgetSpan(
        child: [
          Lottie.asset(EmojiData.lottiePath(emoji), repeat: true, height: 64),
          Text(
            context.read<EmojiData>().tags[emoji]?.first ?? '',
          ).padding(top: 4.0),
        ].toColumn().padding(all: 8.0),
      ),
      child: button,
    );
  }

  void _showThrowEmojiAnimation(BuildContext context) {
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final RenderBox overlay =
        Navigator.of(
              context,
              rootNavigator: true,
            ).overlay!.context.findRenderObject()!
            as RenderBox;
    final position = Rect.fromPoints(
      button.localToGlobal(Offset.zero, ancestor: overlay),
      button.localToGlobal(
        button.size.bottomRight(Offset.zero),
        ancestor: overlay,
      ),
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
          child: SvgPicture(AssetBytesLoader(EmojiData.svgPath(emoji))),
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
  late var _position = Offset(widget.startRect.left, widget.startRect.top);
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  late final _positionTween = Tween(
    begin: 0.0,
    end: 1.0,
  ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_controller);
  late final _sizeTween = TweenSequence<double>([
    TweenSequenceItem(weight: 1.0, tween: Tween(begin: 0, end: -1)),
    TweenSequenceItem(weight: 1.6, tween: Tween(begin: -1, end: 1)),
  ]).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_controller);

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
