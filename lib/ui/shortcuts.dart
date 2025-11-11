import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/utils/extensions/single_activator.dart';

enum ShortcutKey {
  volumeUp,
  volumeDown,
  forward5Sec,
  backward5Sec,
  togglePlay,
  screenshot,
  danmaku,
  voiceVolumeUp,
  voiceVolumeDown,
  muteMic,
}

class ShortcutMappingNotifier
    extends ValueNotifier<Map<ShortcutKey, SingleActivator?>> {
  static const defaultMapping = {
    ShortcutKey.volumeUp: SingleActivator(LogicalKeyboardKey.arrowUp),
    ShortcutKey.volumeDown: SingleActivator(LogicalKeyboardKey.arrowDown),
    ShortcutKey.forward5Sec: SingleActivator(LogicalKeyboardKey.arrowRight),
    ShortcutKey.backward5Sec: SingleActivator(LogicalKeyboardKey.arrowLeft),
    ShortcutKey.togglePlay: SingleActivator(LogicalKeyboardKey.space),
    ShortcutKey.screenshot: SingleActivator(LogicalKeyboardKey.keyS),
    ShortcutKey.danmaku: SingleActivator(LogicalKeyboardKey.keyT),
    ShortcutKey.voiceVolumeUp: SingleActivator(LogicalKeyboardKey.period),
    ShortcutKey.voiceVolumeDown: SingleActivator(LogicalKeyboardKey.comma),
    ShortcutKey.muteMic: SingleActivator(LogicalKeyboardKey.keyM),
  };

  ShortcutMappingNotifier() : super(defaultMapping) {
    bindPreference<String>(
      key: 'shortcut_mapping',
      load: (pref) {
        final savedMap = (jsonDecode(pref) as Map<String, dynamic>)
            .map<String, SingleActivator?>((key, value) {
          final serialized = value as String;
          return MapEntry(
            key,
            serialized.isEmpty ? null : unserializeSingleActivator(serialized),
          );
        });
        final mergedMap = defaultMapping.map<ShortcutKey, SingleActivator?>(
          (key, value) => MapEntry(
              key, savedMap.containsKey(key.name) ? savedMap[key.name] : value),
        );
        return Map.unmodifiable(mergedMap);
      },
      update: (value) => jsonEncode(
        value.map<String, String>(
          (key, value) => MapEntry(key.name, value?.serialize() ?? ''),
        ),
      ),
    );
  }
}

extension ApplyShortcuts on Widget {
  Widget applyShortcuts(Map<ShortcutKey, Intent> mapping) {
    return Consumer<ShortcutMappingNotifier>(
      builder: (context, shortcutMapping, child) => Shortcuts(
        shortcuts: (mapping.map((shortcutKey, intent) =>
                MapEntry(shortcutMapping.value[shortcutKey], intent))
              ..remove(null))
            .map((key, value) => MapEntry(key!, value)),
        child: child!,
      ),
      child: this,
    );
  }
}
