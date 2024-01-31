import 'dart:ui';

import 'package:bunga_player/constants/constants.dart';
import 'package:bunga_player/providers/states/current_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

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

class _EmojiButton extends StatelessWidget {
  final String code;

  const _EmojiButton({required this.code});

  @override
  Widget build(BuildContext context) {
    final svg = SvgPicture.asset(
      'assets/images/emojis/u$code.svg',
      height: 24,
    );

    return IconButton(
      icon: svg,
      onPressed: () {
        // send popmoji
        final currentChannel = context.read<CurrentChannel>();
        currentChannel.send(Message(text: 'popmoji $code'));
        _showThrowEmojiAnimation(context);
        Navigator.of(context).pop();
      },
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

class _ThrowAnimation extends StatefulWidget {
  final Rect startRect, endRect;
  final OverlayEntry overlay;
  final Widget child;
  const _ThrowAnimation({
    required this.startRect,
    required this.endRect,
    required this.child,
    required this.overlay,
  });
  @override
  State<_ThrowAnimation> createState() => _ThrowAnimationState();
}

class _ThrowAnimationState extends State<_ThrowAnimation>
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
  Widget build(BuildContext context) {
    final rect = Rect.lerp(widget.startRect, widget.endRect, _sizeTween.value)!;
    return Stack(
      children: [
        Positioned(
          left: _position.dx,
          top: _position.dy,
          width: rect.width,
          height: rect.height,
          child: widget.child,
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
