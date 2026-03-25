import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:bunga_player/play_sync/play_sync.dart';
import 'package:bunga_player/chat/business.dart';
import 'package:bunga_player/utils/extensions/extensions.dart';
import 'package:bunga_player/screens/widgets/popup_widget.dart';
import 'package:bunga_player/ui/global_business.dart';

import 'blur_chip.dart';

class BusyIndicator extends StatelessWidget {
  const BusyIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer4<
      ShouldShowHUDNotifier,
      BusyStateNotifier,
      PendingWatcherIds?,
      IsSyncPlaying?
    >(
      builder:
          (
            context,
            showHudNotifier,
            isBusyNotifier,
            pendingIds,
            isSyncPlaying,
            child,
          ) {
            String getText() {
              if (isBusyNotifier.isBusy) return '正在加载';

              if (pendingIds == null || pendingIds.isEmpty) return '';

              if (pendingIds.length > 1) return '正在等待多人缓冲';

              final user = context.read<Watchers>().firstWhereOrNull(
                (element) => element.id == pendingIds.first,
              );
              if (user?.isCurrent(context) == true) {
                return '正在缓冲';
              }
              return '正在等待 ${user?.name ?? '神秘人'} 缓冲';
            }

            final text = getText();

            final shouldPop =
                text.isNotEmpty &&
                !showHudNotifier.value &&
                isSyncPlaying?.value != true;
            final shouldCenter = text.isNotEmpty && !shouldPop;
            return PopupWidget(
              showing: shouldPop,
              layoutBuilder: (context, popup) =>
                  popup.padding(all: 24.0).alignment(.bottomLeft),
              popupBuilder: (context) =>
                  [
                        CircularProgressIndicator(
                          strokeCap: StrokeCap.round,
                          strokeWidth: 2.0,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ).constrained(height: 12.0, width: 12.0),
                        Text(text),
                      ]
                      .toRow(
                        separator: const SizedBox(width: 12.0),
                        mainAxisSize: .min,
                      )
                      .padding(vertical: 8.0, left: 20.0, right: 24.0)
                      .blurToast(),
              child:
                  [
                        CircularProgressIndicator(
                          strokeCap: StrokeCap.round,
                        ).constrained(height: 20.0, width: 20.0),
                        Text(
                          text,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ]
                      .toRow(
                        separator: const SizedBox(width: 16.0),
                        mainAxisSize: .min,
                      )
                      .padding(horizontal: 24.0, vertical: 12.0)
                      .boxShadow(
                        color: Theme.of(context).colorScheme.shadow,
                        spreadRadius: 12.0,
                        blurRadius: 36.0,
                      )
                      .opacity(shouldCenter ? 1.0 : 0.0, animate: true)
                      .animate(
                        shouldCenter
                            ? const Duration(milliseconds: 1500)
                            : Duration.zero,
                        Curves.easeOutCubic,
                      )
                      .center(),
            );
          },
    );
  }
}
