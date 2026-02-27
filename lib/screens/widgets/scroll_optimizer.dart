import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

/// Allow scroll dragging for all platform,
/// and mouse wheel works even when scroll is horizontal

class ScrollOptimizer extends SingleChildStatelessWidget {
  final ScrollController scrollController;
  const ScrollOptimizer({
    super.key,
    required super.child,
    required this.scrollController,
  });

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return ScrollConfiguration(
      behavior: _AllowAllDeviceDrag(),
      // HACK: see https://github.com/flutter/flutter/issues/105095
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            scrollController.animateTo(
              scrollController.offset + event.scrollDelta.dy / 2,
              duration: const Duration(milliseconds: 2),
              curve: Curves.bounceIn,
            );
          }
        },
        child: child,
      ),
    );
  }
}

extension ScrollOptimizerStyler on Widget {
  Widget scrollOptimizer(ScrollController controller) {
    return ScrollOptimizer(scrollController: controller, child: this);
  }
}

class _AllowAllDeviceDrag extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}
