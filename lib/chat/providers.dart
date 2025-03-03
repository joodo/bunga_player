import 'dart:async';

import 'package:bunga_player/bunga_server/client.dart';
import 'package:bunga_player/bunga_server/models.dart';
import 'package:bunga_player/client_info/providers.dart';
import 'package:bunga_player/play_sync/models.dart';
import 'package:bunga_player/play_sync/providers.dart';
import 'package:bunga_player/utils/business/auto_retry.dart';
import 'package:bunga_player/utils/business/value_listenable.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'client/client.tencent.dart';
import 'models/channel_data.dart';
import 'models/message.dart';
import 'models/user.dart';
import 'client/client.dart';

class ChatChannelData extends ValueNotifier<ChannelData?> with StreamBinding {
  ChatChannelData() : super(null);
}

typedef LeaveEventListener = void Function({required String userId});
typedef JoinEventListener = void Function({
  required String userId,
  required bool isNew,
});

class ChatChannelLastMessage extends ValueNotifier<Message?>
    with StreamBinding {
  ChatChannelLastMessage() : super(null);
}

final chatProviders = MultiProvider(providers: []);
