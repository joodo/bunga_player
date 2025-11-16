import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

class RestartAppIntent extends Intent {
  const RestartAppIntent();
}

class RestartGlobalBusiness extends SingleChildStatefulWidget {
  const RestartGlobalBusiness({super.key, super.child});

  @override
  State<RestartGlobalBusiness> createState() => _RestartWrapperState();
}

class _RestartWrapperState extends SingleChildState<RestartGlobalBusiness> {
  Key key = UniqueKey();

  void _restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Actions(
      actions: {
        RestartAppIntent: CallbackAction<RestartAppIntent>(
          onInvoke: (intent) => _restartApp(),
        ),
      },
      child: KeyedSubtree(key: key, child: child!),
    );
  }
}
