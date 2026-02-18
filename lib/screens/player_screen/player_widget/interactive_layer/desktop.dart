import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/play/busuness.dart';

import '../chrome_layer/chrome_layer.dart';
import '../chrome_layer/menu_builder.dart';
import 'spark_business.dart';

class DesktopInteractiveLayer extends StatefulWidget {
  const DesktopInteractiveLayer({super.key});

  @override
  State<DesktopInteractiveLayer> createState() =>
      _DesktopInteractiveLayerState();
}

class _DesktopInteractiveLayerState extends State<DesktopInteractiveLayer> {
  // Sparking
  late final SparkSendController _sparkController;

  @override
  void initState() {
    super.initState();
    _sparkController = SparkSendController(context);
  }

  @override
  void dispose() {
    _sparkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuController = MenuController();
    return Consumer<ShouldShowHUDNotifier>(
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
        child: MenuBuilder(
          builder: (context, menuChildren, child) => MenuAnchor(
            controller: menuController,
            consumeOutsideTap: true,
            menuChildren: menuChildren,
            child: child!.center(),
          ),
          child: GestureDetector(
            onTap: Actions.handler(context, ToggleIntent()),
            onDoubleTap: context.read<IsFullScreenNotifier>().toggle,

            onSecondaryTapUp: (details) =>
                menuController.open(position: details.localPosition),

            onSecondaryLongPressStart: (details) {
              _sparkController.start(details.localPosition);
              shouldShowHUDNotifier.lockUp('spark');
            },
            onSecondaryLongPressMoveUpdate: (details) {
              _sparkController.updateOffset(details.localPosition);
            },
            onSecondaryLongPressEnd: (details) {
              _sparkController.stop();
              shouldShowHUDNotifier.unlock('spark');
            },
          ),
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
    if (y > widgetHeight - ChromeLayer.videoControlHeight - 12.0 &&
        y < widgetHeight) {
      return true;
    }

    return false;
  }
}
