import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';

class SliderItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget slider;

  const SliderItem({
    super.key,
    required this.icon,
    required this.title,
    required this.slider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return [
      Icon(icon).iconColor(theme.textTheme.bodyMedium!.color!),
      [
        Text(title).textStyle(theme.textTheme.bodyLarge!).padding(top: 12.0),
        slider.controlSliderTheme(context).padding(left: 2.0),
      ]
          .toColumn(crossAxisAlignment: CrossAxisAlignment.start)
          .padding(left: 16.0)
          .flexible(),
    ].toRow(crossAxisAlignment: CrossAxisAlignment.center);
  }
}
