import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/ui/global_business.dart';

import 'widgets.dart';

class AppearanceSettings extends StatelessWidget with SettingsTab {
  @override
  final label = '外观';
  @override
  final icon = Icons.palette_outlined;
  @override
  final selectedIcon = Icons.palette;

  const AppearanceSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return [
      const Text('窗口').sectionTitle(),
      Consumer<AlwaysOnTopNotifier>(
        builder: (context, alwaysOnTopNotifier, child) => SwitchListTile(
          title: const Text('总在最前'),
          value: alwaysOnTopNotifier.value,
          onChanged: (value) => alwaysOnTopNotifier.value = value,
        ),
      ).sectionContainer(),
    ].toColumn(crossAxisAlignment: CrossAxisAlignment.start);
  }
}
