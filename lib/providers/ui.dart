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

class IsBusy extends ValueNotifier<bool> {
  IsBusy(super.value);
}

class BusinessName extends ValueNotifier<String?> {
  BusinessName(super.value);
}

uiProviders() => [
      ChangeNotifierProvider(create: (context) => IsFullScreen(false)),
      ChangeNotifierProvider(
          create: (context) => IsControlSectionHidden(false)),
      ChangeNotifierProvider(create: (context) => IsBusy(false)),
      ChangeNotifierProvider(create: (context) => BusinessName(null)),
    ];
