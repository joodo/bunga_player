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

class IsControlSectionHidden extends ValueNotifier<bool> {
  IsControlSectionHidden(super.value);
}

uiProviders() => [
      ChangeNotifierProvider(create: (context) => IsFullScreen(false)),
      ChangeNotifierProvider(
          create: (context) => IsControlSectionHidden(false)),
    ];
