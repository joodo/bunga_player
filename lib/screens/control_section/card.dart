import 'package:flutter/material.dart';

class ControlCard extends StatefulWidget {
  final Widget child;

  const ControlCard({super.key, required this.child});

  @override
  State<ControlCard> createState() => _ControlCardState();
}

class _ControlCardState extends State<ControlCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
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
          child: widget.child,
        ),
      ),
    );
  }
}
