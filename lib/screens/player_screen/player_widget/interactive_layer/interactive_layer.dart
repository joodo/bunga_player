import 'package:bunga_player/chat/global_business.dart';
import 'package:bunga_player/chat/models/message_data.dart';
import 'package:bunga_player/danmaku/business.dart';
import 'package:bunga_player/utils/extensions/styled_widget.dart';
import 'package:flutter/material.dart';

import 'package:bunga_player/utils/business/platform.dart';
import 'package:provider/provider.dart';

import 'desktop.dart';
import 'spark_business.dart';
import 'touch.dart';

class InteractiveLayer extends StatelessWidget {
  const InteractiveLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final layer = kIsDesktop
        ? const DesktopInteractiveLayer()
        : const TouchInteractiveLayer();
    return layer.actions(
      actions: {
        SparkIntent: CallbackAction<SparkIntent>(
          onInvoke: (intent) {
            return Actions.invoke(
              context,
              SendMessageIntent(
                SparkMessageData(
                  emoji: context.read<SparkingEmoji>().value,
                  fraction: intent.offset,
                ),
              ),
            );
          },
        ),
      },
    );
  }
}
