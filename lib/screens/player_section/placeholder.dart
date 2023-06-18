import 'package:bunga_player/common/im_controller.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class PlayerPlaceholder extends StatefulWidget {
  final ValueNotifier<String?> textNotifier;
  final ValueNotifier<bool> isAwakeNotifier;

  const PlayerPlaceholder({
    super.key,
    required this.textNotifier,
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
    IMController().currentUserNotifier.addListener(() {
      _isCatAwakeInput.value = IMController().currentUserNotifier.value != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                  },
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
          Positioned(
            top: 340,
            child: ValueListenableBuilder<String?>(
              valueListenable: widget.textNotifier,
              builder: (context, text, child) => Text(
                text ?? '',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}