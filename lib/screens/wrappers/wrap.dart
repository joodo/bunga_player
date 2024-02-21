import 'package:bunga_player/screens/wrappers/toast.dart';
import 'package:flutter/material.dart';

import 'console.dart';
import 'actions.dart';
import 'update.dart';
import 'host_init.dart';
import 'restart.dart';
import 'providers.dart';

Widget wrap(Widget child) {
  child = ConsoleWrapper(child: child);
  child = UpdateWrapper(child: child);
  child = ActionsWrapper(child: child);
  child = ProvidersWrapper(child: child);
  child = HostInitWrapper(child: child);
  child = ToastWrapper(child: child);
  child = RestartWrapper(child: child);
  return child;
}
