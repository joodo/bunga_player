import 'package:async/async.dart';
import 'package:flutter/material.dart';

import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/extensions/rect.dart';

class SparkIntent extends Intent {
  final FractionalOffset offset;
  const SparkIntent(this.offset);
}

class SparkSendController {
  final BuildContext _context;
  SparkSendController(this._context);

  void start(Offset position) {
    _updateVideoRect();
    _createSparkTimer();
    updateOffset(position);
  }

  Rect? _videoRect;
  void _updateVideoRect() {
    final videoSize = getIt<MediaPlayer>().videoSizeNotifier.value;
    if (videoSize == null) {
      _videoRect = null;
      return;
    }

    final renderBox = _context.findRenderObject() as RenderBox?;
    final containerSize = renderBox?.size;
    if (containerSize == null) {
      _videoRect = null;
      return;
    }

    final fittedSizes = applyBoxFit(BoxFit.contain, videoSize, containerSize);
    final Size actualVideoSize = fittedSizes.destination;

    final double dx = (containerSize.width - actualVideoSize.width) / 2;
    final double dy = (containerSize.height - actualVideoSize.height) / 2;

    _videoRect = Offset(dx, dy) & actualVideoSize;
  }

  RestartableTimer? _timer;
  void _createSparkTimer() {
    _timer = RestartableTimer(const Duration(milliseconds: 200), () {
      if (_sparkOffset != null) {
        Actions.maybeInvoke(_context, SparkIntent(_sparkOffset!));
      }
      _timer!.reset();
    });
  }

  FractionalOffset? _sparkOffset;
  void updateOffset(Offset position) {
    if (_videoRect == null) return;

    if (_videoRect!.contains(position)) {
      _sparkOffset = _videoRect!.toFractionalOffset(position);
    } else {
      _sparkOffset = null;
    }
  }

  void stop() {
    _videoRect = null;
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
  }
}
