import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/screens/widgets/back_listener.dart';

import 'player_screen/player_screen.dart';
import 'welcome_screen/welcome_screen.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class BackCallbacks extends DelegatingList<Future<bool> Function()> {
  BackCallbacks(super.base);
}

class _ScreenState extends State<Screen> {
  final _onBackCallbacks = BackCallbacks([]);

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator(
      initialRoute: 'welcome',
      onGenerateRoute: (settings) {
        final widget = switch (settings.name) {
          'welcome' => WelcomeScreen(),
          'player' => PlayerScreen(),
          String() => throw UnimplementedError(),
          null => throw UnimplementedError(),
        };
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => widget.onBackPop(),
        );
      },
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        for (final callback in _onBackCallbacks.reversed) {
          if (await callback()) return;
        }
        SystemNavigator.pop();
      },
      child: Provider.value(value: _onBackCallbacks, child: navigator),
    );
  }
}
