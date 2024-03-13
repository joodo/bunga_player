import 'package:bunga_player/providers/business_indicator.dart';
import 'package:bunga_player/utils/value_listenable.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class IsFullScreen extends ValueNotifier<bool> {
  IsFullScreen() : super(false) {
    addListener(() async {
      windowManager.setFullScreen(value);
    });
    windowManager.isFullScreen().then((value) => this.value = value);
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

class AListInitiated extends ValueNotifier<bool> {
  AListInitiated() : super(false);
}

final uiProviders = MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => BusinessIndicator()),
    ChangeNotifierProvider(create: (context) => IsFullScreen()),
    ChangeNotifierProvider(create: (context) => DanmakuMode()),
    ProxyProvider2<IsFullScreen, DanmakuMode, FoldLayout>(
      update: (context, isFullScreen, danmakuMode, previous) =>
          FoldLayout(isFullScreen.value && !danmakuMode.value),
    ),
    ChangeNotifierProxyProvider2<FoldLayout, BusinessIndicator, ShouldShowHUD>(
      create: (context) {
        final result = ShouldShowHUD();

        if (!context.read<FoldLayout>().value) result.lock('fold');
        if (!context.read<BusinessIndicator>().isRunning) result.lock('busy');

        return result..mark();
      },
      update: (context, foldLayout, businessIndicator, previous) {
        if (!foldLayout.value) {
          previous!.lock('fold');
        } else {
          previous!.unlock('fold');
        }

        if (businessIndicator.isRunning) {
          previous.lock('busy');
        } else {
          previous.unlock('busy');
        }

        return previous;
      },
    ),
    ChangeNotifierProvider(create: (context) => JustToggleByRemote()),
    ChangeNotifierProvider(create: (context) => JustAdjustedVolumeByKey()),
    ChangeNotifierProvider(create: (context) => AListInitiated(), lazy: false),
  ],
);
