import 'package:bunga_player/screens/wrappers/toast.dart';
import 'package:flutter/material.dart';

import 'console.dart';
import 'shortcuts.dart';
import 'update.dart';
import 'host_init.dart';
import 'restart.dart';
import 'providers.dart';

// TODO: use wrapper mixin
Widget wrap(Widget child) {
  child = ConsoleWrapper(child: child);
  child = UpdateWrapper(child: child);
  child = ShortcutsWrapper(child: child);
  child = ProvidersWrapper(child: child);
  child = HostInitWrapper(child: child);
  child = ToastWrapper(child: child);
  child = RestartWrapper(child: child);
  return child;
}
