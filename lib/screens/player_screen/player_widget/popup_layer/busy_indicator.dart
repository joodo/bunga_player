import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/chat/business.dart';
import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/play_sync/business.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/screens/widgets/popup_widget.dart';
import 'package:bunga_player/ui/global_business.dart';

import 'blur_chip.dart';

class BusyIndicator extends StatelessWidget {
  const BusyIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<
      ShouldShowHUDNotifier,
      BusyStateNotifier,
      WatcherBufferingStatusNotifier?
    >(
      builder:
          (
            context,
            showHudNotifier,
            isBusyNotifier,
            bufferingStatusNotifier,
            child,
          ) => ValueListenableBuilder(
            valueListenable: getIt<MediaPlayer>().isBufferingNotifier,
            builder: (context, isBuffering, child) {
              String? getText() {
                if (showHudNotifier.value) return null;

                if (isBusyNotifier.isBusy) return '正在加载';

                if (isBuffering) return '正在缓冲';

                final bufferList = bufferingStatusNotifier?.bufferingUserIds;
                if (bufferList == null || bufferList.isEmpty) return null;

                if (bufferList.length > 1) return '正在等待多人缓冲';

                final user = context.read<Watchers>().firstWhereOrNull(
                  (element) => element.id == bufferList.first,
                );
                if (user != null && user.isCurrent(context) == true) {
                  return null;
                }
                return '正在等待 ${user?.name ?? '神秘人'} 缓冲';
              }

              final text = getText();

              return PopupWidget(
                showing: text != null,
                layoutBuilder: (context, child) =>
                    child.padding(all: 24.0).alignment(.bottomLeft),
                child:
                    [
                          CircularProgressIndicator(
                            strokeCap: StrokeCap.round,
                            strokeWidth: 2.0,
                          ).constrained(height: 12.0, width: 12.0),
                          Text(text ?? ''),
                        ]
                        .toRow(
                          separator: const SizedBox(width: 8.0),
                          mainAxisSize: .min,
                        )
                        .padding(vertical: 8.0, left: 12.0, right: 16.0)
                        .blurChip(),
              );
            },
          ),
    );
  }
}
