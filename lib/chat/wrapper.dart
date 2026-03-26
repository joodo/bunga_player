import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';

import '/console/service.dart';

import 'actions.dart';
import 'business.dart';
import 'models/models.dart';
import 'providers.dart';

class ChatWrapper extends SingleChildStatefulWidget {
  const ChatWrapper({super.key, required Widget super.child});

  @override
  State<ChatWrapper> createState() => _ChatWrapperState();
}

class _ChatWrapperState extends SingleChildState<ChatWrapper> {
  late final _watchersNotifier = WatchersNotifier(myself: User.of(context))
    ..watchInConsole('Watchers');

  @override
  void dispose() {
    _watchersNotifier.dispose();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return child!
        .chatBusiness(watchersNotifier: _watchersNotifier)
        .chatActions()
        .chatProviders(watchersNotifier: _watchersNotifier);
  }
}

extension ChatWrapperExtension on Widget {
  Widget withChat() => ChatWrapper(child: this);
}
