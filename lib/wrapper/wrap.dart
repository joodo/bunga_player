import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';

import 'console.dart';
import 'shortcuts.dart';
import 'update.dart';

Widget wrap(Widget child) {
  child = ConsoleWrapper(child: child);
  child = UpdateWrapper(child: child);
  child = ShortcutsWrapper(child: child);
  child = Portal(child: child);
  return child;
}
