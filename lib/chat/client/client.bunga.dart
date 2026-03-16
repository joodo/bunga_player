import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:bunga_player/bunga_server/models/channel_tokens.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/logger.dart';

import 'client.dart';
import '../models/message.dart';
import '../models/user.dart';

class BungaChatClient extends ChatClient {
  final ChannelTokens _serverInfo;
  BungaChatClient._(ChannelTokens serverInfo) : _serverInfo = serverInfo;

  static Future<BungaChatClient> create({
    required ChannelTokens serverInfo,
  }) async {
    final client = BungaChatClient._(serverInfo);
    await client._connect();
    return client;
  }

  // Messages

  WebSocketChannel? _channel;
  final _streamController = StreamController<Map<String, dynamic>>();
  late final _jsonStream = _streamController.stream.asBroadcastStream();

  @override
  Stream<Message> get messageStream => _jsonStream.map((json) {
    return Message(data: json, sender: User.fromJson(json['sender']));
  });

  static const _ignoreLoggingCodes = {
    'spark',
    'client-status',
    'channel-status',
  };
  @override
  Future<Message?> sendMessage(Map<String, dynamic> data) async {
    final rawData = jsonEncode(data);

    if (_channel == null) {
      logger.w('Chat: websocket not ready, send message later.');
      return null;
    }

    _channel!.sink.add(rawData);
    if (!_ignoreLoggingCodes.contains(data['code'])) {
      logger.i('Chat: send message: $rawData');
    }
    return messageStream.first;
  }

  void onDataReceived(String rawData) {
    _heartbeatTimeoutTimer.reset();

    final json = jsonDecode(rawData);
    if (!_ignoreLoggingCodes.contains(json['code'])) {
      logger.i('Chat: message received: $rawData');
    }
    _streamController.add(json);
  }

  // Connection
  static const _maxRetryDelayMSec = 10_000;
  int retryDelayMSec = 500;
  Future<void> _reconnect({bool backoff = true}) async {
    if (backoff) retryDelayMSec = min(retryDelayMSec * 2, _maxRetryDelayMSec);
    logger.w('Websocket: wait ${retryDelayMSec / 1000}s and try again');
    await Future.delayed(Duration(milliseconds: retryDelayMSec));
    return _connect();
  }

  final _isConnectedNotifier = ValueNotifier<bool>(false);
  @override
  ValueListenable<bool> get isConnectedNotifier => _isConnectedNotifier;

  Future<void> _connect() async {
    final origin = _serverInfo.origin;
    final wsUrl = origin.replace(
      scheme: origin.scheme == 'http' ? 'ws' : 'wss',
      path: 'chat/',
      queryParameters: {
        'token': _serverInfo.token.access,
        'channel_id': _serverInfo.channel.id,
      },
    );
    _channel = IOWebSocketChannel.connect(
      wsUrl.toString(),
      connectTimeout: 5.seconds,
    );

    _channel!.stream.listen(
      (rawData) {
        onDataReceived(rawData);
      },
      onDone: () async {
        _isConnectedNotifier.value = false;

        final closeCode = _channel!.closeCode;
        _channel = null;
        switch (closeCode) {
          case null: // Close by client
            break;

          case 1005 || 1006 || 1015: // Network unstable
          case 1001 || 1011 || 1012 || 1013: // Server problem
            logger.w('Websocket: connection break. Code $closeCode');
            return _reconnect();

          case 1002: // Client unstable
          case 3000: // Break by timer
            logger.w('Websocket: connection break. Code $closeCode');
            return _reconnect(backoff: false);

          case 4002: // Token expired
            await _serverInfo.refreshToken();
            return _connect();

          default:
            logger.e(
              'Websocket: connection break, fatal reasion. Code $closeCode',
            );
            getIt<GlobalKey<ScaffoldMessengerState>>().currentState!
                .showSnackBar(
                  SnackBar(content: const Text(('和服务器沟通失败，部分功能不可用。'))),
                );
        }
      },
    );

    try {
      await _channel!.ready;
      logger.i('Websocket: connect success');
      retryDelayMSec = 500;
      _isConnectedNotifier.value = true;
      _heartbeatTimeoutTimer.reset();
    } on WebSocketChannelException catch (e) {
      logger.w('Websocket: $e');
      _channel = null;
      return _reconnect();
    }
  }

  late final _heartbeatTimeoutTimer = RestartableTimer(3.seconds, () {
    // Already disconnected, _reconnect should be invoked
    if (!_isConnectedNotifier.value) return;

    logger.w('Websocket: heartbeat timeout, break connection.');
    _channel?.sink.close(3000);
  })..cancel();

  @override
  void dispose() {
    _channel?.sink.close(1000);
    _streamController.close();
    _isConnectedNotifier.dispose();
    super.dispose();
  }
}
