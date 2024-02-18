import 'package:bunga_player/utils/value_listenable.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class IsFullScreen extends ValueNotifier<bool> {
  IsFullScreen(super.value) {
    addListener(() async {
      windowManager.setFullScreen(value);
    });
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

uiProviders() => [
      ChangeNotifierProvider(create: (context) => IsFullScreen(false)),
      ChangeNotifierProvider(create: (context) => ShouldShowHUD()),
      ChangeNotifierProvider(create: (context) => IsCatAwake()),
      ChangeNotifierProvider(create: (context) => JustToggleByRemote()),
      ChangeNotifierProvider(create: (context) => JustAdjustedVolumeByKey()),
    ];
