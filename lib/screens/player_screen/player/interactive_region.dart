import 'package:bunga_player/play/busuness.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'ui.dart';

class InteractiveRegion extends StatelessWidget {
  const InteractiveRegion({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShouldShowHUD>(
      builder: (context, shouldShowHUDNotifier, child) => MouseRegion(
        opaque: false,
        cursor: shouldShowHUDNotifier.value
            ? SystemMouseCursors.basic
            : SystemMouseCursors.none,
        onEnter: (event) => shouldShowHUDNotifier.unlock('interactive'),
        onHover: (event) {
          if (_isInUISection(context, event)) {
            shouldShowHUDNotifier.lockUp('interactive');
          } else {
            shouldShowHUDNotifier.unlock('interactive');
            shouldShowHUDNotifier.mark();
          }
        },
        child: GestureDetector(
          onTap: Actions.handler(
            context,
            ToggleIntent(forgetSavedPosition: true),
          ),
          onDoubleTap: context.read<IsFullScreen>().toggle,
        ),
      ),
    );
  }

  bool _isInUISection(BuildContext context, PointerHoverEvent event) {
    final y = event.localPosition.dy;
    final widgetHeight = (context.findRenderObject()! as RenderBox).size.height;

    // In channel section
    if (y < 72.0) return true;

    // In control or progress section
    if (y > widgetHeight - PlayerUI.videoControlHeight - 12.0 &&
        y < widgetHeight) {
      return true;
    }

    return false;
  }
}
