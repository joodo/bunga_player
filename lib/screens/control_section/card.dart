import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

class ControlCard extends SingleChildStatefulWidget {
  const ControlCard({super.key, super.child});

  @override
  State<ControlCard> createState() => _ControlCardState();
}

class _ControlCardState extends SingleChildState<ControlCard> {
  bool _hovered = false;

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return SizedBox(
      height: 48,
      child: MouseRegion(
        onEnter: (event) => setState(() {
          _hovered = true;
        }),
        onExit: (event) => setState(() {
          _hovered = false;
        }),
        child: AnimatedContainer(
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceTint
                .withAlpha(_hovered ? 0x1A : 0x09),
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: child,
        ),
      ),
    );
  }
}
