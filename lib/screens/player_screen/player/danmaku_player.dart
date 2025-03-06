import 'dart:async';
import 'dart:collection';

import 'package:bunga_player/chat/models/message.dart';
import 'package:bunga_player/chat/models/message_data.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

typedef Danmaku = ({String message, User sender});

class DanmakuPlayer extends StatefulWidget {
  const DanmakuPlayer({super.key});

  @override
  State<DanmakuPlayer> createState() => _DanmakuPlayerState();
}

class _DanmakuPlayerState extends State<DanmakuPlayer>
    with SingleTickerProviderStateMixin {
  final _danmakus = <Danmaku>[];
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = context
        .read<Stream<Message>>()
        .where(
            (message) => message.data['type'] == DanmakuMessageData.messageType)
        .map((message) {
      final data = DanmakuMessageData.fromJson(message.data);
      return (sender: data.sender, message: data.message);
    }).listen(_addDanmaku);
    _ticker.start();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _ticker.stop();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const topPadding = 48.0;
    return [
      for (final (line, danmakuPoses) in _danmakuLines.indexed)
        for (final danmakuPos in danmakuPoses)
          Positioned(
            top: line * 48 + topPadding,
            left: danmakuPos.x,
            child: DanmakuText(
              text: danmakuPos.danmaku.message,
              hue: danmakuPos.danmaku.sender.colorHue,
            ),
          ),
    ].toStack();
  }

  static const spacing = 24.0;

  static const preferLines = 5;
  int _currentLine = 0;
  final _danmakuLines = <Queue<DanmakuPosition>>[];

  double _lastAvailablePositions(int line) {
    if (_danmakuLines[line].isEmpty) return 0;

    final danmakuPosition = _danmakuLines[line].last;
    final danmakuWidth = _getStringWidth(danmakuPosition.danmaku.message);

    return danmakuPosition.x + danmakuWidth + spacing;
  }

  double _getStringWidth(String text) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: DanmakuText.textStyle),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.width;
  }

  void _addDanmaku(Danmaku newDanmaku) {
    _danmakus.add(newDanmaku);

    if (!mounted) return;
    final renderBox = context.findRenderObject()! as RenderBox;
    final widgetWidth = renderBox.size.width;

    while (true) {
      if (_danmakuLines.length == _currentLine) {
        // Create new line
        _danmakuLines.add(Queue());
        break;
      } else {
        final availableX = _lastAvailablePositions(_currentLine);

        if (availableX > widgetWidth) {
          // find next line
          _currentLine++;
        } else {
          // found one
          break;
        }
      }
    }

    _danmakuLines[_currentLine].addLast(
      DanmakuPosition(
        danmaku: newDanmaku,
        x: widgetWidth,
      ),
    );
    _currentLine++;

    if (_currentLine >= preferLines) _currentLine = 0;
  }

  late final _ticker = createTicker(_updateDanmaku);
  static const step = 3.0;
  void _updateDanmaku(Duration elapsed) {
    for (final danmakuPoses in _danmakuLines) {
      for (final danmakuPos in danmakuPoses) {
        danmakuPos.x -= step;
      }
      danmakuPoses.removeWhere((danmakuPos) =>
          danmakuPos.x + _getStringWidth(danmakuPos.danmaku.message) < 0);
    }
    setState(() {});

    // If all danmaku clean, reset current line
    for (final danmakuPoses in _danmakuLines) {
      if (danmakuPoses.isNotEmpty) return;
    }
    _currentLine = 0;
  }
}

class DanmakuPosition {
  final Danmaku danmaku;
  double x;

  DanmakuPosition({required this.danmaku, required this.x});
}

class DanmakuText extends StatelessWidget {
  static const textStyle = TextStyle(
    fontSize: 40,
    letterSpacing: 2,
  );

  final String text;
  final int hue;

  const DanmakuText({
    super.key,
    required this.text,
    required this.hue,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = HSVColor.fromAHSV(1, (hue % 360), 0.5, 0.3).toColor();
    final foregroundColor =
        HSVColor.fromAHSV(1, (hue % 360), 0.5, 0.95).toColor();

    return [
      // Stroked text as border.
      Text(text).textStyle(
        textStyle.copyWith(
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = 4
            ..color = borderColor,
        ),
      ),
      // Solid text as fill.
      Text(text).textStyle(textStyle.copyWith(color: foregroundColor)),
    ].toStack();
  }
}
