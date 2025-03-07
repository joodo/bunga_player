import 'dart:async';
import 'dart:convert';
import 'package:bunga_player/bunga_server/models/bunga_client_info.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:path/path.dart' as path_tool;
import 'package:tencent_cloud_chat_sdk/enum/V2TimAdvancedMsgListener.dart';

import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

import '../models/message.dart';
import 'client.dart';

class TencentClient extends ChatClient {
  final int appId;
  final String userId;
  final String userSig;
  final String channelId;
  final StreamController<Message> messageStreamController;

  TencentClient._({
    required this.appId,
    required this.userId,
    required this.userSig,
    required this.channelId,
    required this.messageStreamController,
  });

  static Future<TencentClient> create({
    required BungaClientInfo clientInfo,
    required StreamController<Message> messageStreamController,
  }) async {
    final client = TencentClient._(
      appId: int.parse(clientInfo.im.appId),
      userId: clientInfo.im.userId,
      userSig: clientInfo.im.userSig,
      channelId: clientInfo.channel.id,
      messageStreamController: messageStreamController,
    );

    await client._init();
    await client._login();
    client._listenGroupMessage();

    return client;
  }

  Future<void> _init() async {
    final result = await TencentImSDKPlugin.v2TIMManager.initSDK(
      sdkAppID: appId,
      loglevel: LogLevelEnum.V2TIM_LOG_NONE,
      listener: V2TimSDKListener(),
    );
    assert(result.code == 0);
  }

  Future<void> _login() async {
    final manager = TencentImSDKPlugin.v2TIMManager;

    final result = await manager.login(userID: userId, userSig: userSig);
    assert(result.code == 0, result.desc);
  }

  void _listenGroupMessage() {
    final manager = TencentImSDKPlugin.v2TIMManager.getMessageManager();

    manager.addAdvancedMsgListener(
      listener: V2TimAdvancedMsgListener(
        onRecvNewMessage: (message) async {
          if (message.elemType == MessageElemType.V2TIM_ELEM_TYPE_TEXT) {
            logger.i(
                'Receive message from ${message.sender}: [message.msgID] ${message.textElem!.text}');
            final m = Message(
              id: message.msgID!,
              data: jsonDecode(message.textElem!.text!),
              senderId: message.sender!,
            );
            messageStreamController.add(m);
          }
        },
      ),
    );
  }

  @override
  Future<Message> sendMessage(Map<String, dynamic> data) async {
    final text = jsonEncode(data);
    final manager = TencentImSDKPlugin.v2TIMManager.getMessageManager();
    final createTextMessageRes = await manager.createTextMessage(text: text);
    assert(createTextMessageRes.code == 0);

    final sendMessageRes = await manager.sendMessage(
      id: createTextMessageRes.data!.id!,
      receiver: '',
      groupID: channelId,
    );
    assert(sendMessageRes.code == 0, sendMessageRes.desc);
    final messageId = sendMessageRes.data!.msgID!;

    final message = Message(id: messageId, data: data, senderId: userId);

    // Tencent can't receive self message in group
    messageStreamController.add(message);

    logger.i('Send message: [$messageId] $text');
    return message;
  }

  @override
  Future<String> uploadFile(String path) async {
    final manager = TencentImSDKPlugin.v2TIMManager.getMessageManager();

    final filename = path_tool.basenameWithoutExtension(path);
    final createFileMessageRes = await manager.createFileMessage(
      filePath: path,
      fileName: filename,
    );
    assert(createFileMessageRes.code == 0);

    final sendMessageRes = await manager.sendMessage(
      id: createFileMessageRes.data!.id!,
      receiver: '',
      groupID: channelId,
    );
    assert(sendMessageRes.code == 0, sendMessageRes.desc);

    final getMessageOnlineUrlRes = await manager.getMessageOnlineUrl(
      msgID: sendMessageRes.data!.msgID!,
    );

    final url = getMessageOnlineUrlRes.data!.fileElem!.url!;
    logger.i('Send file $filename: $url');
    return url;
  }
}
