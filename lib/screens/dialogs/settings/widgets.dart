import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

mixin SettingsTab on Widget {
  String get label;
  IconData get icon;
  IconData get selectedIcon;
}

extension SectionTitle on Text {
  Widget sectionTitle() => Builder(
          builder: (context) =>
              textStyle(Theme.of(context).textTheme.labelMedium!))
      .padding(horizontal: 16.0, top: 16.0, bottom: 4.0);
}

extension SectionContainer on Widget {
  Widget sectionContainer() => Builder(
      builder: (context) => DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyLarge!,
            child: this,
          )).card(elevation: 2, clipBehavior: Clip.hardEdge);
}
