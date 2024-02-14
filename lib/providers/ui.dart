import 'package:async/async.dart';
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
  IsControlSectionHidden() : super(false);
}

class IsCatAwake extends ValueNotifier<bool> {
  IsCatAwake() : super(false);
}

class JustToggleByRemote extends ChangeNotifier
    implements ValueListenable<bool> {
  static const Duration cooldown = Duration(seconds: 2);

  bool _value = false;
  @override
  bool get value => _value;

  late final _resetTimer = RestartableTimer(
    cooldown,
    () {
      _value = false;
      notifyListeners();
    },
  )..cancel();

  void mark() {
    _value = true;
    notifyListeners();
    _resetTimer.reset();
  }
}

uiProviders() => [
      ChangeNotifierProvider(create: (context) => IsFullScreen(false)),
      ChangeNotifierProvider(create: (context) => IsControlSectionHidden()),
      ChangeNotifierProvider(create: (context) => IsCatAwake()),
      ChangeNotifierProvider(create: (context) => JustToggleByRemote()),
    ];
