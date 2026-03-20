import 'package:bunga_player/reaction/business.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/ui/global_business.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:bunga_player/play/busuness.dart';

import '../../menu_builder.dart';
import 'spark_send_controller.dart';

class DesktopInteractiveLayer extends StatefulWidget {
  const DesktopInteractiveLayer({super.key});

  @override
  State<DesktopInteractiveLayer> createState() =>
      _DesktopInteractiveLayerState();
}

class _DesktopInteractiveLayerState extends State<DesktopInteractiveLayer> {
  // Sparking
  late final SparkSendController _sparkController;
  bool _isSparking = false;

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
        cursor: shouldShowHUDNotifier.value || _isSparking
            ? SystemMouseCursors.basic
            : SystemMouseCursors.none,
        onHover: (event) {
          if (!_isSparking) shouldShowHUDNotifier.mark();
        },
        child: MenuBuilder(
          builder: (context, menuChildren, child) => MenuAnchor(
            controller: menuController,
            consumeOutsideTap: true,
            menuChildren: menuChildren,
            child: child!.center(),
          ),
          child: GestureDetector(
            onTap: Actions.handler(context, IndirectToggleIntent()),
            onDoubleTap: context.read<IsFullScreenNotifier>().toggle,

            onSecondaryTapUp: (details) =>
                menuController.open(position: details.localPosition),

            onLongPressStart: (details) {
              _sparkController.start(details.localPosition);
              _isSparking = true;
              shouldShowHUDNotifier.reset();
              context.read<SparkBarVisibilityNotifier>().lockUp('sending');
            },
            onLongPressMoveUpdate: (details) {
              _sparkController.updateOffset(details.localPosition);
            },
            onLongPressEnd: (details) {
              _sparkController.stop();
              _isSparking = false;
              context.read<SparkBarVisibilityNotifier>().unlock('sending');
            },
          ),
        ),
      ),
    );
  }
}
