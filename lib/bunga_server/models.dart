sealed class ChatClientInfo {
  final String appKey;
  final String userToken;

  ChatClientInfo({required this.appKey, required this.userToken});
}

class StreamIOClientInfo extends ChatClientInfo {
  StreamIOClientInfo.fromJson(dynamic json)
      : super(
          appKey: json['app_key'],
          userToken: json['user_token'],
        );
}

class TencentClientInfo extends ChatClientInfo {
  TencentClientInfo.fromJson(dynamic json)
      : super(
          appKey: json['app_id'],
          userToken: json['user_sig'],
        );
}

class AListClientInfo {
  final String host;
  final String token;

  AListClientInfo({required this.host, required this.token});
}
