import 'dart:async';
import 'dart:convert';

import 'package:bunga_player/bunga_server/client.dart';
import 'package:bunga_player/chat/models/channel_data.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/utils/models/network_progress.dart';
import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimGroupListener.dart';

import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_full_info.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

import 'client.dart';

final _userInfoCache = <String, User>{};

class _TencentGroup extends Channel {
  _TencentGroup({
    required super.id,
    required super.streams,
    required super.updateData,
    required super.sendMessage,
    required super.uploadFile,
    required super.leave,
  });

  factory _TencentGroup.create({
    required String groupId,
    required ChannelData data,
    required User currentUser,
    required _MessageManager messageManager,
    required _GroupManager groupManager,
  }) {
    final messageStream = messageManager.messageStreamByGroupId(groupId);
    final dataStream = groupManager.dataStreamByGroupId(groupId);
    final fileStream = messageManager.fileStreamByGroupId(groupId);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // init channel data
      groupManager.initGroupData(groupId, data);
    });

    return _TencentGroup(
      id: groupId,
      streams: (
        message: messageStream,
        data: dataStream,
        file: fileStream,
      ),
      sendMessage: (text) => messageManager.sendMessage(
        currentUser,
        groupId,
        text,
      ),
      updateData: (data) => groupManager.updateGroupData(groupId, data),
      uploadFile: (filePath, {description, title}) => messageManager.sendFile(
        currentUser,
        groupId,
        filePath,
        description: description,
        title: title,
      ),
      leave: () => groupManager.quitGroup(groupId),
    );
  }
}

class TencentClient extends ChatClient {
  final int appId;
  final BungaClient bungaClient;
  TencentClient(this.bungaClient)
      : appId = int.parse(bungaClient.chatClientInfo.appKey);

  bool _sdkInitiated = false;
  Future<void> _initSdk() async {
    if (_sdkInitiated) return;

    final result = await TencentImSDKPlugin.v2TIMManager.initSDK(
      sdkAppID: appId,
      loglevel: LogLevelEnum.V2TIM_LOG_NONE,
      listener: V2TimSDKListener(),
    );
    assert(result.code == 0);
    _sdkInitiated = true;
  }

  final _messageManager = _MessageManager();
  final _groupManager = _GroupManager();

  OwnUser? _currentUser;
  @override
  Future<OwnUser> login(
    String id,
    String token,
    String? name, {
    int? colorHue,
  }) async {
    await _initSdk();

    final manager = TencentImSDKPlugin.v2TIMManager;

    if (_currentUser == null) {
      final result = await manager.login(userID: id, userSig: token);
      assert(result.code == 0, result.desc);
    }

    final setSelfInfoRes = await manager.setSelfInfo(
      userFullInfo: V2TimUserFullInfo(
        nickName: name,
        selfSignature: colorHue.toString(),
      ),
    );
    assert(setSelfInfoRes.code == 0, setSelfInfoRes.desc);

    _currentUser = OwnUser(
      id: id,
      name: name!,
      colorHue: colorHue,
      logout: () {
        _currentUser = null;
        return manager.logout();
      },
    );
    return _currentUser!;
  }

  @override
  Future<Channel> joinChannelByData(ChannelData data) async {
    final response = await bungaClient.post(
      'tencent/join-channel',
      {'user_id': _currentUser!.id, 'data': data.toJson()},
    );
    return _createChannel(response);
  }

  @override
  Future<Channel> joinChannelById(String id) async {
    final response = await bungaClient.post(
      'tencent/join-channel',
      {'user_id': _currentUser!.id, 'id': id},
    );
    return _createChannel(response);
  }

  Channel _createChannel(String responseBody) {
    final responseData = jsonDecode(responseBody);
    return _TencentGroup.create(
      groupId: responseData['id'],
      data: ChannelData.fromJson(responseData['data']),
      currentUser: _currentUser!,
      messageManager: _messageManager,
      groupManager: _groupManager,
    );
  }

  @override
  Future<List<ChannelInfo>> queryOnlineChannels() async {
    final response = await bungaClient.get('tencent/online-channels');
    final channels = jsonDecode(response) as List;
    return channels
        .map<ChannelInfo>(
          (e) => (
            id: e['id'] as String,
            data: ChannelData.fromJson(e['data']),
            createAt: DateTime.fromMillisecondsSinceEpoch(
              e['data']['created_at'] * 1000,
              isUtc: true,
            ),
          ),
        )
        .toList();
  }
}

class _MessageManager {
  final _messageStreamController =
      StreamController<({String? groupId, RawMessage message})>.broadcast();
  Stream<RawMessage> messageStreamByGroupId(String groupId) =>
      _messageStreamController.stream
          .where((event) => event.groupId == groupId)
          .map((event) => event.message);

  final _fileStreamController =
      StreamController<({String? groupId, ChannelFile file})>.broadcast();
  Stream<ChannelFile> fileStreamByGroupId(String groupId) =>
      _fileStreamController.stream
          .where((event) => event.groupId == groupId)
          .map((event) => event.file);

  _MessageManager() {
    final manager = TencentImSDKPlugin.v2TIMManager.getMessageManager();

    manager.addAdvancedMsgListener(
      listener: V2TimAdvancedMsgListener(
        onRecvNewMessage: (message) async {
          if (message.elemType == MessageElemType.V2TIM_ELEM_TYPE_TEXT) {
            final m = RawMessage(
              id: message.msgID!,
              text: message.textElem!.text!,
              sender: _userInfoCache[message.sender!] ??
                  User(
                    id: message.sender!,
                    name: message.nickName!,
                  ),
            );

            logger.i('Receive message from ${m.sender.name}: ${m.text}');
            _messageStreamController
                .add((groupId: message.groupID, message: m));
          } else if (message.elemType == MessageElemType.V2TIM_ELEM_TYPE_FILE) {
            final getMessageOnlineUrlRes = await manager.getMessageOnlineUrl(
              msgID: message.msgID!,
            );

            final fileElem = getMessageOnlineUrlRes.data!.fileElem!;
            final info = jsonDecode(fileElem.fileName!);

            final channelFile = ChannelFile(
              id: fileElem.UUID!,
              title: info['t'] ?? 'no title',
              description: info['d'],
              uploader: _userInfoCache[message.sender!] ??
                  User(
                    id: message.sender!,
                    name: message.nickName!,
                  ),
              url: fileElem.url!,
            );
            logger.i(
                'Receive file from ${channelFile.uploader.name}: ${channelFile.title}, ${channelFile.description}');

            _fileStreamController.add((
              groupId: message.groupID,
              file: channelFile,
            ));
          }
        },
      ),
    );
  }

  Future<RawMessage> sendMessage(
    User sender,
    String groupId,
    String text,
  ) async {
    final manager = TencentImSDKPlugin.v2TIMManager.getMessageManager();
    final createTextMessageRes = await manager.createTextMessage(text: text);
    assert(createTextMessageRes.code == 0);

    final sendMessageRes = await manager.sendMessage(
      id: createTextMessageRes.data!.id!,
      receiver: '',
      groupID: groupId,
    );
    assert(sendMessageRes.code == 0, sendMessageRes.desc);
    final messageId = sendMessageRes.data!.msgID!;

    final message = RawMessage(
      id: messageId,
      text: text,
      sender: sender,
    );
    _messageStreamController.add((groupId: groupId, message: message));

    logger.i('Send message: $text');
    return message;
  }

  Stream<RequestProgress> sendFile(
    User sender,
    String groupId,
    String filePath, {
    String? title,
    String? description,
  }) async* {
    final manager = TencentImSDKPlugin.v2TIMManager.getMessageManager();

    final createFileMessageRes = await manager.createFileMessage(
      filePath: filePath,
      fileName: jsonEncode({
        't': title,
        'd': description,
      }),
    );
    assert(createFileMessageRes.code == 0, createFileMessageRes.desc);

    String id = createFileMessageRes.data!.id!;
    final sendMessageRes = await manager.sendMessage(
      id: id,
      receiver: '',
      groupID: groupId,
    );
    assert(sendMessageRes.code == 0, sendMessageRes.desc);

    yield const RequestProgress(current: 1, total: 1);
  }
}

class _GroupManager {
  final _dataStreamController =
      StreamController<({String groupId, ChannelData data})>.broadcast();
  Stream<ChannelData> dataStreamByGroupId(String groupId) =>
      _dataStreamController.stream
          .where((event) => event.groupId == groupId)
          .map((event) => event.data);

  _GroupManager() {
    TencentImSDKPlugin.v2TIMManager.addGroupListener(
      listener: V2TimGroupListener(
        onGroupInfoChanged: (groupID, changeInfos) {
          final changes = <String, dynamic>{};
          for (final info in changeInfos) {
            switch (info.type) {
              case 1:
                changes['name'] = info.value!;
              case 4:
                changes['image'] = jsonDecode(info.value!);
              case 6:
                switch (info.key) {
                  case 'path':
                  case 'video_type':
                    changes[info.key!] = jsonDecode(info.value!);
                  case 'sharer':
                    final userJson = jsonDecode(info.value!);
                    changes['sharer'] =
                        _userInfoCache[userJson['id']]?.toJson() ?? userJson;
                  case 'video_hash':
                    changes['hash'] = jsonDecode(info.value!);
                }
            }
          }
          _dataStreamController.add((
            groupId: groupID,
            data: ChannelData.fromJson(changes),
          ));
        },
      ),
    );
  }

  void initGroupData(String groupId, ChannelData data) {
    _dataStreamController.add((groupId: groupId, data: data));
  }

  Future<void> updateGroupData(String groupId, ChannelData data) async {
    final groupManager = TencentImSDKPlugin.v2TIMManager.getGroupManager();
    final setGroupInfoRes = await groupManager.setGroupInfo(
      info: V2TimGroupInfo(
        groupID: groupId,
        groupType: 'Work',
        groupName: data.name,
        faceUrl: jsonEncode(data.image),
        customInfo: {
          'video_type': jsonEncode(data.videoType.name),
          'video_hash': jsonEncode(data.videoHash),
          'sharer': jsonEncode(data.sharer),
          'path': jsonEncode(data.path),
        },
      ),
    );
    assert(setGroupInfoRes.code == 0, setGroupInfoRes.desc);
  }

  Future<void> quitGroup(String groupId) async {
    final response =
        await TencentImSDKPlugin.v2TIMManager.quitGroup(groupID: groupId);
    assert(response.code == 0, response.desc);
  }
}
