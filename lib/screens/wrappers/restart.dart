import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

class RestartWrapper extends SingleChildStatefulWidget {
  const RestartWrapper({super.key, super.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWrapperState>()!.restartApp();
  }

  @override
  State<RestartWrapper> createState() => _RestartWrapperState();
}

class _RestartWrapperState extends SingleChildState<RestartWrapper> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return KeyedSubtree(key: key, child: child!);
  }
}
