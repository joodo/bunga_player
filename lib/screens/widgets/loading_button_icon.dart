import 'package:flutter/material.dart';

class LoadingButtonIcon extends StatelessWidget {
  const LoadingButtonIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: IconTheme.of(context).size,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: CircularProgressIndicator(
          color: DefaultTextStyle.of(context).style.color,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
