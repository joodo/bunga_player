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

class IsCatAwake extends ValueNotifier<bool> {
  IsCatAwake() : super(false);
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

final uiProviders = MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => IsFullScreen()),
    ChangeNotifierProvider(
        create: (context) => ShouldShowHUD()..mark(lock: true)),
    ChangeNotifierProvider(create: (context) => IsCatAwake()),
    ChangeNotifierProvider(create: (context) => JustToggleByRemote()),
    ChangeNotifierProvider(create: (context) => JustAdjustedVolumeByKey()),
  ],
);
