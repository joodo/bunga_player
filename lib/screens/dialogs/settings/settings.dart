import 'package:animations/animations.dart';
import 'package:bunga_player/screens/dialogs/settings/widgets.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import 'about.dart';
import 'network.dart';
import 'appearance.dart';
import 'reaction.dart';
import 'shortcut.dart';

class SettingsDialog extends StatefulWidget {
  final Type? page;

  const SettingsDialog({super.key, this.page});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  int _selectedIndex = 0;
  bool _reverse = false;

  final _tabs = <SettingsTab>[
    const ReactionSettings(),
    if (kIsDesktop) const AppearanceSettings(),
    const ShortcutSettings(),
    const NetworkSettings(),
    const AboutSetting(),
  ];

  @override
  void initState() {
    super.initState();

    for (final entry in _tabs.asMap().entries) {
      if (entry.value.runtimeType == widget.page) {
        _selectedIndex = entry.key;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return [
      NavigationRail(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) => setState(() {
          _reverse = _selectedIndex > value;
          _selectedIndex = value;
        }),
        labelType: NavigationRailLabelType.all,
        destinations: _tabs
            .map((tab) => NavigationRailDestination(
                  icon: Icon(tab.icon),
                  selectedIcon: Icon(tab.selectedIcon),
                  label: Text(tab.label),
                ))
            .toList(),
      ).padding(top: 16.0),
      const VerticalDivider(width: 0),
      [
        PageTransitionSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation, secondaryAnimation) =>
              SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.vertical,
            child: child,
          ),
          reverse: _reverse,
          child: KeyedSubtree(
            key: ValueKey<int>(_selectedIndex),
            child: _tabs[_selectedIndex]
                .padding(top: 16.0)
                .constrained(
                  maxWidth: 480,
                  minHeight: MediaQuery.of(context).size.height - 16.0,
                )
                .alignment(Alignment.topCenter)
                .scrollable(padding: EdgeInsets.only(bottom: 16.0)),
          ),
        ),
        StyledWidget(IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        )).padding(top: 8.0, right: 16.0).alignment(Alignment.topRight),
      ].toStack().flexible(),
    ].toRow();
  }
}
