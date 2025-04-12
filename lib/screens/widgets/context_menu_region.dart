import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

class ContextMenuRegion<T> extends SingleChildStatelessWidget {
  final List<PopupMenuEntry<T>> items;
  final void Function(T? value)? onSelected;

  const ContextMenuRegion({
    super.key,
    required this.items,
    this.onSelected,
    super.child,
  });

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return GestureDetector(
      onLongPressStart: (details) {
        _showMenu(context, details.globalPosition);
      },
      onSecondaryTapDown: (details) {
        _showMenu(context, details.globalPosition);
      },
      child: child,
    );
  }

  void _showMenu(BuildContext context, Offset position) async {
    final selected = await showMenu(
      context: context,
      useRootNavigator: true,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: items,
    );
    onSelected?.call(selected);
  }
}
