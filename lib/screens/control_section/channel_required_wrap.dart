import 'package:bunga_player/chat/providers.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ChannelRequiredWrap extends Selector<ChatChannel, VoidCallback?> {
  ChannelRequiredWrap({
    super.key,
    super.child,
    required super.builder,
    required VoidCallback? action,
  }) : super(
            selector: (context, channelId) =>
                channelId.value == null ? null : action);
}
