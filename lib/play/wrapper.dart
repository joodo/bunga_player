import 'package:bunga_player/play/actions.dart';
import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';

import 'package:bunga_player/console/service.dart';

import 'business.dart';
import 'models/models.dart';
import 'providers.dart';
import 'payload_parser.dart';

class PlayWrapper extends SingleChildStatefulWidget {
  const PlayWrapper({super.key, required Widget super.child});

  @override
  State<PlayWrapper> createState() => _PlayWrapperState();
}

class _PlayWrapperState extends SingleChildState<PlayWrapper> {
  final _playPayloadNotifier = ValueNotifier<PlayPayload?>(null)
    ..watchInConsole('Play Payload');
  final _dirInfoNotifier = ValueNotifier<DirInfo?>(null);

  @override
  void dispose() {
    _dirInfoNotifier.dispose();
    _playPayloadNotifier.dispose();

    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return child!
        .playBusiness(
          playPayloadNotifier: _playPayloadNotifier,
          dirInfoNotifier: _dirInfoNotifier,
        )
        .playActions(
          playPayloadNotifier: _playPayloadNotifier,
          dirInfoNotifier: _dirInfoNotifier,
        )
        .playProviders(
          playPayloadNotifier: _playPayloadNotifier,
          dirInfoNotifier: _dirInfoNotifier,
        );
  }
}

extension PlayExtension on Widget {
  Widget withPlay() => PlayWrapper(child: this);
}
