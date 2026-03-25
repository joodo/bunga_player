import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/utils/business/list_wrapper.dart';
import 'package:bunga_player/chat/models/models.dart';

typedef ChannelSubtitle = ({String title, String url, User sharer});

class SubtitleTrackIdOfUrl {
  final value = <String, String>{};
}

@immutable
class PendingWatcherIds extends ListWrapper<String> {
  PendingWatcherIds([super.initial = const []]);
}

extension PlaySyncProvidersExtension on Widget {
  Widget playSyncProviders({
    required final ValueNotifier<PendingWatcherIds> pendingWatcherIdsNotifier,
    required final ValueNotifier<ChannelSubtitle?> channelSubtitleNotifier,
  }) => MultiProvider(
    providers: [
      ValueListenableProvider.value(value: channelSubtitleNotifier),
      ValueListenableProvider.value(value: pendingWatcherIdsNotifier),
      Provider(create: (context) => SubtitleTrackIdOfUrl()),
    ],
    child: this,
  );
}
