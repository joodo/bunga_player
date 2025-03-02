import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

class AppWrapper extends SingleChildStatelessWidget {
  const AppWrapper({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return SafeArea(
      child: MaterialApp(
        theme: Theme.of(context),
        home: child,
      ),
    );
  }
}
