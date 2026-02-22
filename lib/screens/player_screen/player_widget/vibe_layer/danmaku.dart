import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/chat/models/models.dart';
import 'package:bunga_player/danmaku/models/models.dart';

class DanmakuTextPainter {
  static const textStyle = TextStyle(fontSize: 40, letterSpacing: 2);

  late final TextPainter strokePainter;
  late final TextPainter fillPainter;

  late final Size size;

  final String _text;
  DanmakuTextPainter({required String message, required int hue})
    : _text = message {
    strokePainter = TextPainter(textDirection: TextDirection.ltr);
    fillPainter = TextPainter(textDirection: TextDirection.ltr);

    updateColor(hue);

    size = fillPainter.size;
  }

  void updateColor(int hue) {
    final borderColor = HSVColor.fromAHSV(1, (hue % 360), 0.5, 0.3).toColor();
    final foregroundColor = HSVColor.fromAHSV(
      1,
      (hue % 360),
      0.5,
      0.95,
    ).toColor();

    strokePainter.text = TextSpan(
      text: _text,
      style: textStyle.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 4
          ..color = borderColor,
      ),
    );
    fillPainter.text = TextSpan(
      text: _text,
      style: textStyle.copyWith(color: foregroundColor),
    );

    strokePainter.layout();
    fillPainter.layout();
  }
}

class DanmakuLayer extends StatefulWidget {
  const DanmakuLayer({super.key});

  @override
  State<DanmakuLayer> createState() => _DanmakuLayerState();
}

class _DanmakuLayerState extends State<DanmakuLayer>
    with SingleTickerProviderStateMixin {
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = context
        .read<Stream<Message>>()
        .where(
          (message) => message.data['code'] == DanmakuMessageData.messageCode,
        )
        .map((message) {
          final data = DanmakuMessageData.fromJson(message.data);
          return DanmakuTextPainter(
            message: data.message,
            hue: message.sender.colorHue,
          );
        })
        .listen((painter) {
          _danmakuLines.addPainter(painter);
          if (_ticker.muted) _ticker.muted = false;
        });
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
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _danmakuLines,
        builder: (context, child) => CustomPaint(
          painter: _DanmakuPainter(_danmakuLines),
          size: Size.infinite,
        ),
      ),
    );
  }

  late final _danmakuLines = _DanmakuLines(
    getWidgetWidth: () {
      if (!mounted) return null;
      final renderBox = context.findRenderObject()! as RenderBox;
      return renderBox.size.width;
    },
  );

  late final _ticker = createTicker(_updateDanmaku);
  Duration _lastElapsed = Duration.zero;
  void _updateDanmaku(Duration elapsed) {
    final delta = elapsed - _lastElapsed;
    _lastElapsed = elapsed;
    if (delta <= Duration.zero || delta > const Duration(milliseconds: 500)) {
      // Avoid visual glitches upon resuming the Ticker
      return;
    }

    final hasActive = _danmakuLines.updatePosition(delta);
    if (!hasActive) _ticker.muted = true;
  }
}

class _DanmakuPainter extends CustomPainter {
  static const topPadding = 48.0;
  static const lineHeight = 48.0;
  final _DanmakuLines danmakuLines;

  _DanmakuPainter(this.danmakuLines);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < danmakuLines.length; i++) {
      final y = i * lineHeight + topPadding;
      for (final dp in danmakuLines[i]) {
        dp.painter.strokePainter.paint(canvas, Offset(dp.x, y));
        dp.painter.fillPainter.paint(canvas, Offset(dp.x, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _DanmakuPosition {
  final DanmakuTextPainter painter;
  double x;

  _DanmakuPosition({required this.painter, required this.x});
}

class _DanmakuLines extends ListBase<Queue<_DanmakuPosition>>
    with ChangeNotifier {
  static const spacing = 24.0;
  static const preferLines = 5;
  static const double pixelsPerSecond = 200.0;

  final double? Function() _getWidgetWidth;

  _DanmakuLines({required double? Function() getWidgetWidth})
    : _getWidgetWidth = getWidgetWidth;

  int _currentLine = 0;

  void addPainter(DanmakuTextPainter painter) {
    final widgetWidth = _getWidgetWidth();
    if (widgetWidth == null) return;

    while (true) {
      if (_data.length == _currentLine) {
        // Create new line
        _data.add(Queue());
        break;
      } else {
        final availableX = _lastAvailablePositions(_currentLine);

        if (availableX > painter.size.width) {
          // find next line
          _currentLine++;
        } else {
          // found one
          break;
        }
      }
    }

    _data[_currentLine].addLast(
      _DanmakuPosition(painter: painter, x: widgetWidth),
    );
    _currentLine++;

    if (_currentLine >= preferLines) _currentLine = 0;
  }

  double _lastAvailablePositions(int line) {
    if (_data[line].isEmpty) return 0;

    final danmakuPosition = _data[line].last;
    final danmakuWidth = danmakuPosition.painter.size.width;

    return danmakuPosition.x + danmakuWidth + spacing;
  }

  bool updatePosition(Duration delta) {
    bool hasActive = false;

    final step =
        pixelsPerSecond * delta.inMicroseconds / Duration.microsecondsPerSecond;
    for (final danmakuPoses in _data) {
      for (final danmakuPos in danmakuPoses) {
        danmakuPos.x -= step;
      }

      // Remove out range danmaku
      while (danmakuPoses.isNotEmpty &&
          danmakuPoses.first.x + danmakuPoses.first.painter.size.width < 0) {
        danmakuPoses.removeFirst();
      }

      if (danmakuPoses.isNotEmpty) hasActive = true;
    }

    if (hasActive) {
      notifyListeners();
    } else {
      // If all danmaku clean, reset current line
      _currentLine = 0;
    }
    return hasActive;
  }

  final _data = <Queue<_DanmakuPosition>>[];
  @override
  int get length => _data.length;
  @override
  set length(int newLength) => _data.length = length;
  @override
  Queue<_DanmakuPosition> operator [](int index) => _data[index];
  @override
  void operator []=(int index, Queue<_DanmakuPosition> value) =>
      _data[index] = value;
}
