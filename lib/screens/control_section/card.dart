import 'package:flutter/material.dart';

class ControlCard extends StatelessWidget {
  final Widget child;

  const ControlCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceTint.withAlpha(0x1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}
