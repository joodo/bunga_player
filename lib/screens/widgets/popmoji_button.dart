import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/danmaku/models/emoji_data.dart';
import 'package:bunga_player/screens/player_screen/player_screen.dart';

class PopmojiButton extends StatelessWidget {
  final String emoji;
  final VoidCallback? onPressed;
  final void Function(bool isHovered)? onHover;
  final double size;

  const PopmojiButton(
    this.emoji, {
    super.key,
    this.onPressed,
    this.onHover,
    required this.size,
  });

  double get _iconSize => size - 12;

  @override
  Widget build(BuildContext context) {
    final iconWidget = EmojiData.createIcon(emoji, _iconSize - 8.0);

    return InkWell(
      onTap: () {
        _showThrowEmojiAnimation(context);
        onPressed?.call();
      },
      onHover: onHover,
      borderRadius: BorderRadius.circular(64.0),
      child: iconWidget.padding(all: 8.0),
    );
  }

  void _showThrowEmojiAnimation(BuildContext context) async {
    // Calc
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

    // Create icon
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontFamily: EmojiData.fontFamily, fontSize: _iconSize),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);

    // Create image
    final img = await EmojiData.createImage(emoji, _iconSize);

    // Throw
    final playerBox =
        PlayerScreen.playerKey.currentContext!.findRenderObject()! as RenderBox;
    final playerLocalCenter = Offset(
      playerBox.size.width / 2,
      playerBox.size.height / 2,
    );
    final playerCenter = playerBox.localToGlobal(
      playerLocalCenter,
      ancestor: overlay,
    );

    late final OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return _ThrowAnimation(
          startRect: position,
          endRect: Rect.fromPoints(playerCenter, playerCenter),
          overlay: overlayEntry,
          child: RawImage(image: img, filterQuality: FilterQuality.low),
        );
      },
    );
    if (!context.mounted) return;
    Overlay.of(context, rootOverlay: true).insert(overlayEntry);
  }
}

class _ThrowAnimation extends SingleChildStatefulWidget {
  static const duration = Duration(milliseconds: 1000);
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
  late final PathMetric _pathMetric;
  late final double _pathLength;

  late final _controller = AnimationController(
    vsync: this,
    duration: _ThrowAnimation.duration,
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

    final path = Path()
      ..moveTo(widget.startRect.left, widget.startRect.top)
      ..quadraticBezierTo(
        widget.startRect.left,
        widget.endRect.top,
        widget.endRect.left,
        widget.endRect.top,
      );
    final pathMetrics = path.computeMetrics();
    _pathMetric = pathMetrics.first;
    _pathLength = _pathMetric.length;

    _controller.forward().then((_) => widget.overlay.remove());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final distance = _pathLength * _positionTween.value;
        final position = _pathMetric.getTangentForOffset(distance)!.position;

        final rect = Rect.lerp(
          widget.startRect,
          widget.endRect,
          _sizeTween.value,
        )!;

        final scaleX = rect.width / widget.startRect.width;
        final scaleY = rect.height / widget.startRect.height;

        return child!
            .transform(
              transform: Matrix4.diagonal3Values(scaleX, scaleY, 1.0),
              alignment: Alignment.center,
            )
            .positioned(left: position.dx, top: position.dy);
      },
      child: child,
    );
  }
}
