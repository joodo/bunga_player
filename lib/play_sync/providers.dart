import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '/chat/models/models.dart';
import '/utils/utils.dart';

typedef ChannelSubtitle = ({String title, String url, User sharer});

class SubtitleTrackIdOfUrl {
  final value = <String, String>{};
}

class IsSyncPlaying {
  final bool value;
  IsSyncPlaying(this.value);
}

@immutable
class PendingWatcherIds extends ListWrapper<String> {
  PendingWatcherIds([super.initial = const []]);
}

extension PlaySyncProvidersExtension on Widget {
  Widget playSyncProviders({
    required final ValueNotifier<PendingWatcherIds> pendingWatcherIdsNotifier,
    required final ValueNotifier<ChannelSubtitle?> channelSubtitleNotifier,
    required ValueNotifier<bool> isSyncPlaying,
  }) => MultiProvider(
    providers: [
      ValueListenableProvider.value(value: channelSubtitleNotifier),
      ValueListenableProvider.value(value: pendingWatcherIdsNotifier),
      ValueListenableProxyProvider(
        valueListenable: isSyncPlaying,
        proxy: (value) => IsSyncPlaying(value),
      ),
      Provider(create: (context) => SubtitleTrackIdOfUrl()),
    ],
    child: this,
  );
}
