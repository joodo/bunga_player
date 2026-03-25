import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';

import 'package:bunga_player/console/service.dart';

import 'actions.dart';
import 'business.dart';
import 'providers.dart';

class PlaySyncWrapper extends SingleChildStatefulWidget {
  const PlaySyncWrapper({super.key, required Widget super.child});

  @override
  State<PlaySyncWrapper> createState() => _PlaySyncWrapperState();
}

class _PlaySyncWrapperState extends SingleChildState<PlaySyncWrapper> {
  final _pendingWatcherIdsNotifier = ValueNotifier<PendingWatcherIds>(
    PendingWatcherIds([]),
  )..watchInConsole('Watchers Pending Ids');
  final _channelSubtitleNotifier = ValueNotifier<ChannelSubtitle?>(null)
    ..watchInConsole('Channel Subtitle');
  final _isSyncPlaying = ValueNotifier<bool>(false);
  final _businessPayload = BusinessPayload();

  @override
  void dispose() {
    _pendingWatcherIdsNotifier.dispose();
    _businessPayload.dispose();
    _isSyncPlaying.dispose();

    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return child!
        .playSyncBusiness(
          pendingWatcherIdsNotifier: _pendingWatcherIdsNotifier,
          channelSubtitleNotifier: _channelSubtitleNotifier,
          isSyncPlaying: _isSyncPlaying,
          business: _businessPayload,
        )
        .playSyncActions(
          business: _businessPayload,
          isSyncPlaying: _isSyncPlaying,
        )
        .playSyncProviders(
          channelSubtitleNotifier: _channelSubtitleNotifier,
          pendingWatcherIdsNotifier: _pendingWatcherIdsNotifier,
          isSyncPlaying: _isSyncPlaying,
        );
  }
}

extension PlaySyncExtension on Widget {
  Widget withPlaySync() => PlaySyncWrapper(child: this);
}
