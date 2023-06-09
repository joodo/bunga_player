import 'package:bunga_player/controllers/ui_notifiers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class PlayerPlaceholder extends StatefulWidget {
  final ValueListenable<bool> isAwakeNotifier;

  const PlayerPlaceholder({
    super.key,
    required this.isAwakeNotifier,
  });

  @override
  State<PlayerPlaceholder> createState() => _PlayerPlaceholderState();
}

class _PlayerPlaceholderState extends State<PlayerPlaceholder> {
  late final SMIBool _isCatAwakeInput;

  @override
  void initState() {
    super.initState();
    widget.isAwakeNotifier.addListener(() {
      _isCatAwakeInput.value = widget.isAwakeNotifier.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 400,
                  child: RiveAnimation.asset(
                    'assets/images/wake_up_the_black_cat.riv',
                    onInit: (Artboard artboard) {
                      final controller = StateMachineController.fromArtboard(
                          artboard, 'State Machine 1');
                      artboard.addController(controller!);

                      _isCatAwakeInput =
                          controller.findInput<bool>('isWaken') as SMIBool;
                      _isCatAwakeInput.value = widget.isAwakeNotifier.value;
                    },
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
            Positioned(
              top: 340,
              child: ValueListenableBuilder<String?>(
                valueListenable: UINotifiers().hintText,
                builder: (context, text, child) => Text(
                  text ?? '',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
