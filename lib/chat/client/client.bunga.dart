import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bunga_player/services/services.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:bunga_player/bunga_server/models/channel_tokens.dart';
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

  final _messageRawBuffer = <String>[];
  static const _ignoreLoggingCodes = {'spark'};
  @override
  Future<Message?> sendMessage(Map<String, dynamic> data) async {
    final rawData = jsonEncode(data);

    if (_channel == null) {
      _messageRawBuffer.add(rawData);
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
    final json = jsonDecode(rawData);
    if (!_ignoreLoggingCodes.contains(json['code'])) {
      logger.i('Chat: message received: $rawData');
    }
    _streamController.add(json);
  }

  // Connection
  static const _maxRetryDelayMSec = 10_000;
  Future<void> _reconnect() {
    late int retryDelayMSec;

    Future<void> doReconnect() async {
      retryDelayMSec = min(retryDelayMSec * 2, _maxRetryDelayMSec);
      logger.w('Websocket: wait ${retryDelayMSec / 1000}s and try again');
      await Future.delayed(Duration(milliseconds: retryDelayMSec));
      return _connect();
    }

    retryDelayMSec = 500;
    return doReconnect();
  }

  Future<void> _connect() async {
    final origin = _serverInfo.origin;
    final wsUrl = origin.replace(
      scheme: origin.scheme == 'http' ? 'ws' : 'wss',
      path: 'chat/${_serverInfo.channel.id}/',
      queryParameters: {'token': _serverInfo.token.access},
    );
    _channel = WebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
      (rawData) {
        onDataReceived(rawData);
      },
      onDone: () async {
        final closeCode = _channel!.closeCode;
        switch (closeCode) {
          case null: // Close by client
            break;

          case 1005 || 1006 || 1015: // Network unstable
          case 1011: // Server error
            logger.w('Websocket: connection break. Code $closeCode');
            return _reconnect();

          case 4002: // Token expired
            await _serverInfo.refreshToken();
            return _connect();

          default:
            logger.e(
              'Websocket: connection break, fatal reasion. Code $closeCode',
            );
            _channel = null;
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

      for (final rawData in _messageRawBuffer) {
        _channel!.sink.add(rawData);
        logger.i('Chat: send delayed message: $rawData');
      }
      _messageRawBuffer.clear();
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
