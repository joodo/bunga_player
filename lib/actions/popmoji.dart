import 'package:bunga_player/services/chat.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

Future<void> sendPopmoji(String code) =>
    Chat().sendMessage(Message(text: 'popmoji $code'));
