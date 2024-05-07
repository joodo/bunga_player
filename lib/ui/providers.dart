import 'dart:convert';

import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/extensions/single_activator.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
    addListener(() {
      windowManager.setTitle(value);
    });
    notifyListeners();
  }
}

class ShouldShowHUD extends AutoResetNotifier {
  ShouldShowHUD() : super(const Duration(seconds: 3));
}

class JustToggleByRemote extends AutoResetNotifier {
  JustToggleByRemote() : super(const Duration(seconds: 2));
}

class JustAdjustedVolumeByKey extends AutoResetNotifier {
  JustAdjustedVolumeByKey() : super(const Duration(seconds: 2));
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
}

class ShortcutMapping
    extends ValueNotifier<Map<ShortcutKey, SingleActivator?>> {
  static const defaultMapping = {
    ShortcutKey.volumeUp: SingleActivator(LogicalKeyboardKey.arrowUp),
    ShortcutKey.volumeDown: SingleActivator(LogicalKeyboardKey.arrowDown),
    ShortcutKey.forward5Sec: SingleActivator(LogicalKeyboardKey.arrowRight),
    ShortcutKey.backward5Sec: SingleActivator(LogicalKeyboardKey.arrowLeft),
    ShortcutKey.togglePlay: SingleActivator(LogicalKeyboardKey.space),
    ShortcutKey.screenshot:
        SingleActivator(LogicalKeyboardKey.keyS, control: true),
    ShortcutKey.danmaku: SingleActivator(LogicalKeyboardKey.keyT),
  };

  ShortcutMapping() : super(defaultMapping) {
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
    ProxyProvider2<IsFullScreen, DanmakuMode, FoldLayout>(
      update: (context, isFullScreen, danmakuMode, previous) =>
          FoldLayout(isFullScreen.value && !danmakuMode.value),
    ),
    ChangeNotifierProxyProvider2<FoldLayout, CatIndicator, ShouldShowHUD>(
      create: (context) {
        final result = ShouldShowHUD();

        if (!context.read<FoldLayout>().value) result.lock('fold');
        if (!context.read<CatIndicator>().busy) result.lock('busy');

        return result..mark();
      },
      update: (context, foldLayout, businessIndicator, previous) {
        if (!foldLayout.value) {
          previous!.lock('fold');
        } else {
          previous!.unlock('fold');
        }

        if (businessIndicator.busy) {
          previous.lock('busy');
        } else {
          previous.unlock('busy');
        }

        return previous;
      },
    ),
    ChangeNotifierProvider(create: (context) => JustToggleByRemote()),
    ChangeNotifierProvider(create: (context) => JustAdjustedVolumeByKey()),
    ChangeNotifierProvider(create: (context) => PendingBungaHost()),
    ChangeNotifierProvider(
      create: (context) => ShowRemainDuration(),
      lazy: false,
    ),
    ChangeNotifierProvider(create: (context) => AutoJoinChannel()),
    ChangeNotifierProvider(create: (context) => ShortcutMapping()),
  ],
);
