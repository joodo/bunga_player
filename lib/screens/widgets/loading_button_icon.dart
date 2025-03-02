import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

class LoadingButtonIcon extends StatelessWidget {
  const LoadingButtonIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final size = IconTheme.of(context).size;
    return StyledWidget(CircularProgressIndicator(
      color: DefaultTextStyle.of(context).style.color,
      strokeWidth: 2,
    )).padding(all: 4.0).constrained(width: size, height: size);
  }
}
