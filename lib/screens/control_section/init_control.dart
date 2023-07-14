import 'package:bunga_player/controllers/ui_notifiers.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/services/get_it.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/tokens.dart';
import 'package:bunga_player/services/voice_call.dart';
import 'package:flutter/material.dart';

class InitControl extends StatelessWidget {
  const InitControl({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initFunc(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final hasUserName =
                getIt<Preferences>().get<String>('user_name') != null;
            Future.microtask(() {
              UINotifiers().isBusy.value = false;
              Navigator.of(context).popAndPushNamed(
                  'control:${hasUserName ? 'welcome' : 'rename'}');
            });
          }
          return const SizedBox.shrink();
        });
  }

  Future<void> _initFunc() async {
    // [1]
    await Tokens().init();

    // [2]
    Chat().init();
    VoiceCall().init();
  }
}
