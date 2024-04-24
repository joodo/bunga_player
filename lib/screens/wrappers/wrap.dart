import 'package:bunga_player/actions/wrapper.dart';
import 'package:bunga_player/providers/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

import 'console.dart';
import 'update_and_clean.dart';
import 'restart.dart';
import 'toast.dart';

Widget wrap(SingleChildStatelessWidget app, Widget child) {
  return Nested(
    children: [
      const RestartWrapper(),
      const ProvidersWrapper(),
      ActionsWrapper(),
      const ToastWrapper(),
      app,
      const UpdateAndCleanWrapper(),
      const ConsoleWrapper(),
    ],
    child: child,
  );
}
