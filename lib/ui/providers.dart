import 'dart:convert';

import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:bunga_player/utils/extensions/single_activator.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:window_manager/window_manager.dart';

class AlwaysOnTop extends ValueNotifier<bool> {
  AlwaysOnTop() : super(false) {
    addListener(() async {
      final fullscreen = await windowManager.isFullScreen();
      if (fullscreen) return;

      windowManager.setAlwaysOnTop(value);
    });
    bindPreference<bool>(
      preferences: getIt<Preferences>(),
      key: 'always_on_top',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

class IsFullScreen extends ValueNotifier<bool> {
  final AlwaysOnTop alwaysOnTop;
  IsFullScreen(this.alwaysOnTop) : super(false) {
    if (!kIsDesktop) {
      value = true;
      return;
    }

    addListener(() async {
      if (value) {
        await windowManager.setAlwaysOnTop(false);
        await windowManager.setFullScreen(true);
      } else {
        await windowManager.setFullScreen(false);
        await windowManager.setAlwaysOnTop(alwaysOnTop.value);
      }
    });
    windowManager.isFullScreen().then((value) => this.value = value);
  }
}

class WindowTitle extends ValueNotifierWithReset<String> {
  WindowTitle() : super('👍 棒嘎大影院，你我来相见') {
    if (!kIsDesktop) return;
    addListener(() {
      windowManager.setTitle(value);
    });
    notifyListeners();
  }
}

class ShouldShowHUD extends AutoResetNotifier {
  ShouldShowHUD() : super(Duration(seconds: kIsDesktop ? 3 : 5));
}

class JustToggleByRemote extends AutoResetNotifier {
  JustToggleByRemote() : super(const Duration(seconds: 2));
}

enum ShortHandAction { volume, deviceVolume, deviceBrightness }

class JustAdjustedByShortHand extends AutoResetNotifier {
  JustAdjustedByShortHand() : super(const Duration(seconds: 2));

  ShortHandAction? _action;
  ShortHandAction? get action => _action;
  void markWithAction(ShortHandAction action) {
    _action = action;
    notifyListeners();
    mark();
  }
}

class DanmakuMode extends ValueNotifier<bool> {
  DanmakuMode() : super(false);
}

class FoldLayout {
  final bool value;

  FoldLayout(this.value);
}

class CatIndicator extends ChangeNotifier {
  String? _title;
  String? get title => _title;
  set title(String? value) {
    if (value == _title) return;
    _title = value;
    notifyListeners();
  }

  bool __busy = false;
  bool get busy => __busy;
  set _busy(bool newValue) {
    if (newValue == __busy) return;
    __busy = newValue;
    notifyListeners();
  }

  Future<T> run<T>(Future<T> Function() job) async {
    final oldTitle = _title;
    _busy = true;
    try {
      return await job();
    } catch (e) {
      _title = oldTitle;
      rethrow;
    } finally {
      _busy = false;
    }
  }
}

class PendingBungaHost extends ValueNotifier<bool> {
  PendingBungaHost() : super(false);
}

class ShowRemainDuration extends ValueNotifier<bool> {
  ShowRemainDuration() : super(false) {
    bindPreference<bool>(
      preferences: getIt<Preferences>(),
      key: 'show_remain_duration',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

class AutoJoinChannel extends ValueNotifier<bool> {
  AutoJoinChannel() : super(true) {
    bindPreference<bool>(
      preferences: getIt<Preferences>(),
      key: 'auto_join_channel',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

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
      preferences: getIt<Preferences>(),
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

class ScreenBrightnessNotifier extends ValueNotifier<double> {
  ScreenBrightnessNotifier() : super(0) {
    ScreenBrightness().setAnimate(false);
    ScreenBrightness().current.then((brightness) {
      value = brightness;
      addListener(() {
        ScreenBrightness().setScreenBrightness(value);
      });
    });
  }
}

final uiProviders = MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => CatIndicator()),
    ChangeNotifierProvider(
      create: (context) => AlwaysOnTop(),
      lazy: false,
    ),
    ChangeNotifierProvider(
      create: (context) => IsFullScreen(context.read<AlwaysOnTop>()),
    ),
    ChangeNotifierProvider(
      create: (context) => WindowTitle(),
      lazy: false,
    ),
    ChangeNotifierProvider(create: (context) => DanmakuMode()),
    ChangeNotifierProvider(
      create: (context) => ScreenBrightnessNotifier(),
      lazy: false,
    ),
    ProxyProvider2<IsFullScreen, DanmakuMode, FoldLayout>(
      update: (context, isFullScreen, danmakuMode, previous) =>
          FoldLayout(isFullScreen.value && !danmakuMode.value),
    ),
    ChangeNotifierProvider<ShouldShowHUD>(
      create: (context) => ShouldShowHUD()..mark(),
    ),
    ChangeNotifierProvider(create: (context) => JustToggleByRemote()),
    ChangeNotifierProvider(create: (context) => JustAdjustedByShortHand()),
    ChangeNotifierProvider(create: (context) => PendingBungaHost()),
    ChangeNotifierProvider(
      create: (context) => ShowRemainDuration(),
      lazy: false,
    ),
    ChangeNotifierProvider(create: (context) => AutoJoinChannel()),
    ChangeNotifierProvider(create: (context) => ShortcutMappingNotifier()),
  ],
);
