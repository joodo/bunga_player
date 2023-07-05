import 'package:bunga_player/services/voice_call.dart';
import 'package:flutter/material.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/tokens.dart';

class AsyncInit extends StatelessWidget {
  final Widget child;

  const AsyncInit({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFunc(),
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.done
              ? child
              : const Material(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
    );
  }

  Future<void> _initFunc() async {
    await Preferences().init();
    await Tokens().init();
    Chat().init();
    await VoiceCall().init();
  }
}
