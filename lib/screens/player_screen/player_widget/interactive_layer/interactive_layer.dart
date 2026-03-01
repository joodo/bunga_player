import 'package:flutter/material.dart';

import 'package:bunga_player/utils/business/platform.dart';

import 'desktop.dart';
import 'touch.dart';

class InteractiveLayer extends StatelessWidget {
  const InteractiveLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return kIsDesktop
        ? const DesktopInteractiveLayer()
        : const TouchInteractiveLayer();
  }
}
