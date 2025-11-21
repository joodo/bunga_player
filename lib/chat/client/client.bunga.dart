import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bunga_player/bunga_server/models/bunga_server_info.dart';
import 'package:bunga_player/chat/models/message.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/toast.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'client.dart';

class BungaChatClient extends ChatClient {
  final BungaServerInfo _clientInfo;
  BungaChatClient._(BungaServerInfo clientInfo) : _clientInfo = clientInfo;

  static Future<BungaChatClient> create({
    required BungaServerInfo serverInfo,
  }) async {
    final client = BungaChatClient._(serverInfo);
    await client._connect();
    return client;
  }

  // Messages

  WebSocketChannel? _channel;
  final _streamController = StreamController();
  late final _rawStream = _streamController.stream.asBroadcastStream();

  @override
  Stream<Message> get messageStream => _rawStream.map((rawData) {
    final json = jsonDecode(rawData);
    return Message(data: json, senderId: json['sender']);
  });

  @override
  Future<Message?> sendMessage(Map<String, dynamic> data) async {
    final rawData = jsonEncode(data);
    logger.i('Chat: send message: $rawData');

    if (_channel == null) {
      logger.e('Chat: websocket not ready, send message failed.');
      return null;
    }

    _channel!.sink.add(rawData);
    return messageStream.first;
  }

  void onDataReceived(String rawData) {
    logger.i('Chat: message received: $rawData');
    _streamController.add(rawData);
  }

  // Connection
  static const _maxRetryDelayMSec = 10_000;
  int _retryDelayMSec = 500;
  Future<void> _reconnect() async {
    _retryDelayMSec = min(_retryDelayMSec * 2, _maxRetryDelayMSec);
    logger.w('Websocket: wait ${_retryDelayMSec / 1000}s and try again');
    await Future.delayed(Duration(milliseconds: _retryDelayMSec));
    return _connect();
  }

  Future<void> _connect() async {
    final origin = _clientInfo.origin;
    final wsUrl = origin.replace(
      scheme: origin.scheme == 'http' ? 'ws' : 'wss',
      path: 'chat/${_clientInfo.channel.id}/',
      queryParameters: {'token': _clientInfo.token.access},
    );
    _channel = WebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
      (rawData) {
        _retryDelayMSec = 500;
        onDataReceived(rawData);
      },
      onDone: () async {
        final closeCode = _channel!.closeCode;
        switch (closeCode) {
          case null: // Close by client
            break;

          case 1005 || 1006 || 1015: // Network unstable
            logger.w('Websocket: connection break. Code $closeCode');
            return _reconnect();

          case 4002: // Token expired
            await _clientInfo.refreshToken();
            return _connect();

          default:
            logger.e(
              'Websocket: connection break, fatal reasion. Code $closeCode',
            );
            _channel = null;
            getIt<Toast>().show('和服务器沟通失败，部分功能不可用。');
        }
      },
    );

    try {
      await _channel!.ready;
    } on WebSocketChannelException catch (e) {
      logger.w('Websocket: $e');
      _channel = null;
      return _reconnect();
    }
  }

  @override
  void dispose() {
    _channel?.sink.close(1000);
    _streamController.close();
    super.dispose();
  }
}
