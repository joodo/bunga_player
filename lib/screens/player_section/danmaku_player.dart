import 'dart:collection';

import 'package:bunga_player/danmaku/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DanmakuPlayer extends StatefulWidget {
  const DanmakuPlayer({super.key});

  @override
  State<DanmakuPlayer> createState() => _DanmakuPlayerState();
}

class _DanmakuPlayerState extends State<DanmakuPlayer>
    with SingleTickerProviderStateMixin {
  final _danmakus = <Danmaku>[];
  late final _lastDanmaku = context.read<LastDanmakuNotifier>();

  @override
  void initState() {
    super.initState();
    _lastDanmaku.addListener(_processDanmaku);
    _ticker.start();
  }

  @override
  void dispose() {
    _lastDanmaku.removeListener(_processDanmaku);
    _ticker.stop();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const topPadding = 48.0;
    return Stack(
      children: [
        for (final (line, danmakuPoses) in _danmakuLines.indexed)
          for (final danmakuPos in danmakuPoses)
            Positioned(
              top: line * 48 + topPadding,
              left: danmakuPos.x,
              child: DanmakuText(
                text: danmakuPos.danmaku.text,
                hue: danmakuPos.danmaku.sender.colorHue,
              ),
            ),
      ],
    );
  }

  void _processDanmaku() {
    final newDanmaku = context.read<LastDanmakuNotifier>().value;
    if (newDanmaku == null) return;

    _danmakus.add(newDanmaku);
    _addDanmakuToDisplay(newDanmaku);
  }

  static const spacing = 24.0;

  static const preferLines = 5;
  int _currentLine = 0;
  final _danmakuLines = <Queue<DanmakuPosition>>[];

  double _lastAvailablePositions(int line) {
    if (_danmakuLines[line].isEmpty) return 0;

    final danmakuPosition = _danmakuLines[line].last;
    final danmakuWidth = _getStringWidth(danmakuPosition.danmaku.text);

    return danmakuPosition.x + danmakuWidth + spacing;
  }

  double _getStringWidth(String text) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: DanmakuText.textStyle),
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.width;
  }

  void _addDanmakuToDisplay(Danmaku newDanmaku) {
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
          danmakuPos.x + _getStringWidth(danmakuPos.danmaku.text) < 0);
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

    return Stack(
      children: <Widget>[
        // Stroked text as border.
        Text(
          text,
          style: textStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..strokeWidth = 4
              ..color = borderColor,
          ),
        ),
        // Solid text as fill.
        Text(
          text,
          style: textStyle.copyWith(color: foregroundColor),
        ),
      ],
    );
  }
}
