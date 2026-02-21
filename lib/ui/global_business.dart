import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:window_manager/window_manager.dart';

import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/utils/models/volume.dart';
import 'package:bunga_player/services/exit_callbacks.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/business/platform.dart';
import 'package:bunga_player/utils/business/simple_event.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';

import 'shortcuts.dart';
import 'audio_player.dart';

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
  AutoJoinChannelNotifier() : super(false) {
    bindPreference<bool>(
      key: 'auto_join_channel',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

class DialogShareModeNotifier extends ValueNotifier<bool> {
  DialogShareModeNotifier() : super(true) {
    bindPreference<bool>(
      key: 'dialog_share_mode',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

class ScreenBrightnessNotifier extends ValueNotifier<double> {
  ScreenBrightnessNotifier() : super(0) {
    if (kIsDesktop) return;

    ScreenBrightness().setAnimate(false);
    ScreenBrightness().application.then((brightness) {
      value = brightness;
      addListener(() {
        ScreenBrightness().setApplicationScreenBrightness(value);
      });
    });
  }
}

class BusyStateNotifier extends ChangeNotifier {
  final _reasons = <String>[];
  bool get isBusy => _reasons.isNotEmpty;

  void add(String reason) {
    if (_reasons.contains(reason)) return;
    _reasons.add(reason);
    notifyListeners();
  }

  void remove(String reason) {
    if (_reasons.remove(reason)) notifyListeners();
  }

  @override
  String toString() {
    return _reasons.toString();
  }
}

class PlaySyncMessageManager {
  PlaySyncMessageManager();

  final _streamController = StreamController<String>.broadcast();
  Stream<String> get messageStream => _streamController.stream;
  void show(String message) {
    _streamController.add(message);
  }
}

class PlayToggleVisualSignal extends SimpleEvent {
  PlayToggleVisualSignal();
}

enum AdjustIndicatorEventType {
  brightness,
  volume,
  voiceVolume,
  mediaVolume,
  micMute,
  lockScreen,
}

class AdjustIndicatorEvent extends Stream<AdjustIndicatorEventType> {
  final _controller = StreamController<AdjustIndicatorEventType>.broadcast();

  @override
  StreamSubscription<AdjustIndicatorEventType> listen(
    void Function(AdjustIndicatorEventType event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => _controller.stream.listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  void fire(AdjustIndicatorEventType eventType) => _controller.add(eventType);

  void dispose() {
    _controller.close();
  }
}

class MediaVolumeNotifier extends VolumeNotifier {
  MediaVolumeNotifier() : super(preferenceKey: 'media_volume') {
    if (kIsDesktop) {
      // Wait for MediaPlayer register
      Future.microtask(() {
        addListener(() {
          getIt<MediaPlayer>().volumeNotifier.value = value;
        });
        loadFromPref();
      });
    } else {
      FlutterVolumeController.updateShowSystemUI(false);
      FlutterVolumeController.getVolume().then((level) {
        if (level != null) value = Volume(level: level);
        addListener(() {
          FlutterVolumeController.setVolume(value.mute ? 0.0 : value.level);
        });
      });
    }
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

    getIt<ExitCallbacks>().setShutter(() {
      return Future.delayed(const Duration(milliseconds: 3000));
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
        ChangeNotifierProvider(create: (context) => DialogShareModeNotifier()),
        ChangeNotifierProvider(create: (context) => ShortcutMappingNotifier()),
        ChangeNotifierProvider(
          create: (context) =>
              BusyStateNotifier()..watchInConsole('Busy State'),
        ),
        Provider.value(value: BungaAudioPlayer()),
        Provider.value(value: PlaySyncMessageManager()),
        ChangeNotifierProvider(create: (context) => PlayToggleVisualSignal()),
        Provider(
          create: (context) => AdjustIndicatorEvent(),
          dispose: (context, stream) => stream.dispose(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (context) => MediaVolumeNotifier(),
          lazy: false,
        ),
      ],
      child: child,
    );
  }
}
