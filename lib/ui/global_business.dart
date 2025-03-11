import 'dart:convert';

import 'package:bunga_player/services/exit_callbacks.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:bunga_player/utils/extensions/single_activator.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:window_manager/window_manager.dart';

class AlwaysOnTopNotifier extends ValueNotifier<bool> {
  AlwaysOnTopNotifier() : super(false) {
    addListener(() async {
      final fullscreen = await windowManager.isFullScreen();
      if (fullscreen) return;

      windowManager.setAlwaysOnTop(value);
    });
    bindPreference<bool>(
      key: 'always_on_top',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

class IsFullScreenNotifier extends ValueNotifier<bool> {
  final AlwaysOnTopNotifier alwaysOnTop;
  IsFullScreenNotifier(this.alwaysOnTop) : super(false) {
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

class WindowTitleNotifier extends ValueNotifierWithReset<String> {
  WindowTitleNotifier() : super('👍 棒嘎大影院，你我来相见') {
    if (!kIsDesktop) return;
    addListener(() {
      windowManager.setTitle(value);
    });
    notifyListeners();
  }
}

class ShouldShowHUDNotifier extends AutoResetNotifier {
  ShouldShowHUDNotifier() : super(Duration(seconds: kIsDesktop ? 3 : 5));
}

class ScreenLockedNotifier extends ValueNotifier<bool> {
  ScreenLockedNotifier() : super(false);
}

class AutoJoinChannelNotifier extends ValueNotifier<bool> {
  AutoJoinChannelNotifier() : super(true) {
    bindPreference<bool>(
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
    ScreenBrightness().application.then((brightness) {
      value = brightness;
      addListener(() {
        ScreenBrightness().setApplicationScreenBrightness(value);
      });
    });
  }
}

class UIGlobalBusiness extends SingleChildStatefulWidget {
  const UIGlobalBusiness({super.key, super.child});

  @override
  State<UIGlobalBusiness> createState() => _UIGlobalBusinessState();
}

class _UIGlobalBusinessState extends SingleChildState<UIGlobalBusiness> {
  @override
  void initState() {
    super.initState();

    getIt<ExitCallbacks>().setShutter(() async {
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CircularProgressIndicator()
            .constrained(height: 32.0, width: 32.0)
            .center(),
      );
      await Future.delayed(const Duration(milliseconds: 3000));
    });
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AlwaysOnTopNotifier(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (context) =>
              IsFullScreenNotifier(context.read<AlwaysOnTopNotifier>()),
        ),
        ChangeNotifierProvider(
          create: (context) => WindowTitleNotifier(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (context) => ScreenBrightnessNotifier(),
          lazy: false,
        ),
        ChangeNotifierProvider<ShouldShowHUDNotifier>(
          create: (context) => ShouldShowHUDNotifier()..mark(),
        ),
        ChangeNotifierProvider<ScreenLockedNotifier>(
          create: (context) => ScreenLockedNotifier(),
        ),
        ChangeNotifierProvider(create: (context) => AutoJoinChannelNotifier()),
        ChangeNotifierProvider(create: (context) => ShortcutMappingNotifier()),
      ],
      child: child,
    );
  }
}
