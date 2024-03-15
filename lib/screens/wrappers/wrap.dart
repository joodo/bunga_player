import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

import 'console.dart';
import '../../actions/wrapper.dart';
import 'update.dart';
import 'host_init.dart';
import 'restart.dart';
import 'providers.dart';
import 'toast.dart';

Widget wrap(Widget child) {
  return Nested(
    children: [
      const RestartWrapper(),
      const ToastWrapper(),
      const ProvidersWrapper(),
      const HostInitWrapper(),
      ActionsWrapper(),
      const UpdateWrapper(),
      const ConsoleWrapper(),
    ],
    child: child,
  );
}
