import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/ui/theme.dart';
import 'package:bunga_player/update/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

import 'package:bunga_player/screens/welcome_screen/welcome_screen.dart';
import 'package:bunga_player/console/wrapper.dart';

import 'global_business.dart';

class WrappedWidget extends Nested {
  WrappedWidget({super.key})
    : super(
        children: [
          const GlobalBusiness(),
          const AppWrapper(),
          const ConsoleWrapper(),
          const UpdateWrapper(),
          const NavigatorWrapper(), // Keep app in closer navigator
        ],
        child: const WelcomeScreen(),
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

class NavigatorWrapper extends SingleChildStatelessWidget {
  const NavigatorWrapper({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Navigator(
      onGenerateRoute: (settings) =>
          MaterialPageRoute(builder: (context) => child!),
    );
  }
}
