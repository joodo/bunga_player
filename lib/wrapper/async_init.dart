import 'package:bunga_player/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:bunga_player/services/voice_call.dart';
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
      builder: (context, snapshot) => snapshot.connectionState ==
              ConnectionState.done
          ? child
          : Material(
              color: Colors.black,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: kControlSectionHeight,
                    child:
                        Container(color: Theme.of(context).colorScheme.surface),
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    height: 4,
                    bottom: kControlSectionHeight - 2,
                    child: LinearProgressIndicator(),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _initFunc() async {
    // [1]
    await Preferences().init();

    // [2]
    await Tokens().init();

    // [3]
    await Chat().init();
    await VoiceCall().init();
  }
}
