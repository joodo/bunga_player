import 'package:bunga_player/chat/providers.dart';
import 'package:bunga_player/ui/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

class PlayerPlaceholder extends StatefulWidget {
  const PlayerPlaceholder({super.key});

  @override
  State<PlayerPlaceholder> createState() => _PlayerPlaceholderState();
}

class _PlayerPlaceholderState extends State<PlayerPlaceholder> {
  late final SMIBool _isCatAwakeInput;

  @override
  void initState() {
    super.initState();

    final currentUser = context.read<ChatUser>();
    currentUser.addListener(() {
      _isCatAwakeInput.value = currentUser.value != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 370,
                  child: RiveAnimation.asset(
                    'assets/images/wake_up_the_black_cat.riv',
                    onInit: (Artboard artboard) {
                      final controller = StateMachineController.fromArtboard(
                          artboard, 'State Machine 1');
                      artboard.addController(controller!);

                      _isCatAwakeInput =
                          controller.findInput<bool>('isWaken') as SMIBool;
                      _isCatAwakeInput.value = false;
                    },
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
            Positioned(
              top: 320,
              child: Text(
                context.select<CatIndicator, String?>((bi) => bi.title) ?? '',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
