import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/ui/toast.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

import 'theme.dart';

class AppWrapper extends SingleChildStatelessWidget {
  const AppWrapper({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(child != null);

    return MaterialApp(
      theme: darkTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            getIt<Toast>().register(ScaffoldMessenger.of(context));
            return child!;
          },
        ),
      ),
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
