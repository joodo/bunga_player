import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

import 'package:bunga_player/console/wrapper.dart';
import 'package:bunga_player/screens/screen.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/ui/theme.dart';
import 'package:bunga_player/update/wrapper.dart';

import 'global_business.dart';

class WrappedWidget extends Nested {
  WrappedWidget({super.key})
    : super(
        children: [
          const GlobalBusiness(),
          const AppWrapper(),
          const ConsoleWrapper(),
          const UpdateWrapper(),
        ],
        child: const Screen(),
      );
}

class AppWrapper extends SingleChildStatelessWidget {
  const AppWrapper({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(child != null);

    return MaterialApp(
      theme: darkTheme,
      scaffoldMessengerKey: getIt<GlobalKey<ScaffoldMessengerState>>(),
      home: Scaffold(body: child!),
    );
  }
}
