import 'package:flutter/material.dart';

class AsyncInit extends StatelessWidget {
  final Future<void> Function() asyncFunc;
  final Widget child;

  const AsyncInit({super.key, required this.asyncFunc, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: asyncFunc(),
      builder: (context, snapshot) =>
          snapshot.hasData ? const SizedBox.shrink() : child,
    );
  }
}
