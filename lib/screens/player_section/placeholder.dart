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
  SMIBool? _isCatAwakeInput;
  late final _cat = RiveAnimation.asset(
    key: UniqueKey(),
    'assets/images/wake_up_the_black_cat.riv',
    onInit: (Artboard artboard) {
      final controller =
          StateMachineController.fromArtboard(artboard, 'State Machine 1');
      artboard.addController(controller!);

      if (_isCatAwakeInput == null) {
        _isCatAwakeInput = controller.findInput<bool>('isWaken') as SMIBool;
        _isCatAwakeInput!.value = false;
      } else {
        final last = _isCatAwakeInput!.value;
        _isCatAwakeInput = controller.findInput<bool>('isWaken') as SMIBool;
        _isCatAwakeInput!.value = last;
      }
    },
  );

  @override
  void initState() {
    super.initState();

    final currentUser = context.read<ChatUser>();
    currentUser.addListener(() {
      _isCatAwakeInput!.value = currentUser.value != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxHeight >= 500) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 230,
                  child: OverflowBox(
                    alignment: const Alignment(0, 0.3),
                    maxHeight: 400,
                    child: _cat,
                  ),
                ),
                Text(
                  context.select<CatIndicator, String?>((bi) => bi.title) ?? '',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            );
          } else {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  child: OverflowBox(
                    alignment: const Alignment(0, -1),
                    maxWidth: 330,
                    child: _cat,
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: Text(
                    context.select<CatIndicator, String?>((bi) => bi.title) ??
                        '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
