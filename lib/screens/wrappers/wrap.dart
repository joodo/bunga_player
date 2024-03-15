import 'package:bunga_player/actions/wrapper.dart';
import 'package:bunga_player/providers/wrapper.dart';
import 'package:bunga_player/services/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

import 'console.dart';
import 'update.dart';
import 'restart.dart';
import 'toast.dart';

Widget wrap(Widget child) {
  return Nested(
    children: [
      const RestartWrapper(),
      const ToastWrapper(),
      const ProvidersWrapper(),
      const ServicesWrapper(),
      ActionsWrapper(),
      const UpdateWrapper(),
      const ConsoleWrapper(),
    ],
    child: child,
  );
}
