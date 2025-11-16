import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

import 'theme.dart';

class ThemeWrapper extends SingleChildStatelessWidget {
  const ThemeWrapper({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(child != null);

    return MaterialApp(
      theme: darkTheme,
      home: child!.material(),
    );
  }
}

class AppWrapper extends SingleChildStatelessWidget {
  const AppWrapper({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MaterialApp(
      theme: Theme.of(context),
      home: child!,
    );
  }
}
