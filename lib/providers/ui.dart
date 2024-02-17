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

class _AutoResetNotifier extends ChangeNotifier
    implements ValueListenable<bool> {
  _AutoResetNotifier(this.cooldown);

  final Duration cooldown;

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
  @override
  void dispose() {
    _resetTimer.cancel();
    super.dispose();
  }

  void mark() {
    _value = true;
    notifyListeners();
    _resetTimer.reset();
  }
}

class JustToggleByRemote extends _AutoResetNotifier {
  JustToggleByRemote() : super(const Duration(seconds: 2));
}

class JustAdjustedVolumeByKey extends _AutoResetNotifier {
  JustAdjustedVolumeByKey() : super(const Duration(seconds: 2));
}

uiProviders() => [
      ChangeNotifierProvider(create: (context) => IsFullScreen(false)),
      ChangeNotifierProvider(create: (context) => IsControlSectionHidden()),
      ChangeNotifierProvider(create: (context) => IsCatAwake()),
      ChangeNotifierProvider(create: (context) => JustToggleByRemote()),
      ChangeNotifierProvider(create: (context) => JustAdjustedVolumeByKey()),
    ];
