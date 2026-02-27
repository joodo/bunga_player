import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/client_info/models/client_account.dart';
import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/play/models/play_payload.dart';
import 'package:bunga_player/services/logger.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/utils/business/run_after_build.dart';
import 'package:bunga_player/utils/extensions/http_response.dart';
import 'package:bunga_player/utils/typedef.dart';

import 'models/channel_tokens.dart';

class FetchingChannelTokens {
  final bool value;
  const FetchingChannelTokens(this.value);
}

class BungaHostAddress {
  final String value;
  const BungaHostAddress(this.value);
  Uri get uri => Uri.parse(value);
}

class ConnectToHostIntent extends Intent {
  final String url;
  const ConnectToHostIntent(this.url);
}

class ConnectToHostAction extends ContextAction<ConnectToHostIntent> {
  final ValueNotifier<FetchingChannelTokens> fetchingNotifier;
  final ValueNotifier<ChannelTokens?> tokensNotifier;
  final ValueNotifier<BungaHostAddress> hostNotifier;

  ConnectToHostAction({
    required this.fetchingNotifier,
    required this.tokensNotifier,
    required this.hostNotifier,
  });

  @override
  Future<ChannelTokens?> invoke(
    ConnectToHostIntent intent, [
    BuildContext? context,
  ]) async {
    final read = context!.read;
    final account = read<ClientAccount>();

    late final http.Response response;
    try {
      fetchingNotifier.value = FetchingChannelTokens(true);
      final registerUrl = Uri.parse(intent.url);
      response = await http.post(registerUrl, body: account.toJson());
      if (!response.isSuccess) {
        throw Exception('Login failed: ${response.body}');
      }

      final responseData = jsonDecode(response.body);
      tokensNotifier.value = ChannelTokens.fromJson({
        ...responseData,
        'origin': registerUrl.origin,
      });

      hostNotifier.value = BungaHostAddress(intent.url);

      return tokensNotifier.value;
    } catch (e) {
      logger.e('Cannot connect to server ${intent.url}: $e');
      return null;
    } finally {
      fetchingNotifier.value = FetchingChannelTokens(false);
    }
  }
}

class UploadSubtitleIntent extends Intent {
  final String path;
  const UploadSubtitleIntent(this.path);
}

class UploadSubtitleAction extends ContextAction<UploadSubtitleIntent> {
  @override
  Future<Uri> invoke(
    UploadSubtitleIntent intent, [
    BuildContext? context,
  ]) async {
    assert(context != null);
    final read = context!.read;
    final serverInfo = read<ChannelTokens>();
    final recordId = read<PlayPayload>().record.id;
    final filePath = intent.path;

    final uploadUri = serverInfo.origin.replace(
      pathSegments: [
        'api',
        'channels',
        serverInfo.channel.id,
        'records',
        recordId,
        'subtitle',
      ],
    );

    Future<http.Response> reqFunc(Map<String, String> headers) async {
      final request = http.MultipartRequest('POST', uploadUri);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.headers.addAll(headers);
      final streamedResponse = await request.send();
      return http.Response.fromStream(streamedResponse);
    }

    try {
      final json = await _retryIfTokenExpired(
        serverInfo: serverInfo,
        doRequest: reqFunc,
      );
      return Uri.parse(json['file']);
    } catch (e) {
      throw Exception('Subtitle upload failed: $e');
    }
  }
}

class DoServerRequestIntent extends Intent {
  final Future<http.Response> Function(Uri origin, Map<String, String> headers)
  reqFunc;

  const DoServerRequestIntent({required this.reqFunc});
}

class DoServerRequestAction extends ContextAction<DoServerRequestIntent> {
  @override
  Future<JsonMap> invoke(
    DoServerRequestIntent intent, [
    BuildContext? context,
  ]) {
    final serverInfo = context!.read<ChannelTokens>();
    return _retryIfTokenExpired(
      serverInfo: serverInfo,
      doRequest: (headers) {
        return intent.reqFunc(serverInfo.origin, headers);
      },
    );
  }
}

class UploadLogIntent extends Intent {
  const UploadLogIntent();
}

class UploadLogAction extends ContextAction<UploadLogIntent> {
  @override
  Object? invoke(UploadLogIntent intent, [BuildContext? context]) async {
    final serverInfo = context!.read<ChannelTokens>();

    Future<http.Response> reqFunc(Map<String, String> headers) async {
      final uploadUri = serverInfo.origin.replace(
        pathSegments: ['api', 'client-logs', ''],
      );

      final request = http.MultipartRequest('POST', uploadUri);
      request.files.add(
        await http.MultipartFile.fromPath('file', logger.latestPath),
      );
      request.fields['channel_id'] = serverInfo.channel.id;
      request.headers.addAll(headers);
      final streamedResponse = await request.send();
      return http.Response.fromStream(streamedResponse);
    }

    final json = await _retryIfTokenExpired(
      serverInfo: serverInfo,
      doRequest: reqFunc,
    );
    return json;
  }
}

class BungaServerGlobalBusiness extends SingleChildStatefulWidget {
  const BungaServerGlobalBusiness({super.key, super.child});

  @override
  State<BungaServerGlobalBusiness> createState() =>
      _BungaServerGlobalBusinessState();
}

class _BungaServerGlobalBusinessState
    extends SingleChildState<BungaServerGlobalBusiness> {
  final _serverInfoNotifier = ValueNotifier<ChannelTokens?>(null)
    ..watchInConsole('Bunga Server Info');
  final _fetchingNotifier = ValueNotifier<FetchingChannelTokens>(
    FetchingChannelTokens(false),
  );
  final _hostAddressNotifier =
      ValueNotifier<BungaHostAddress>(BungaHostAddress(''))
        ..bindPreference<String>(
          key: 'bunga_host',
          load: (pref) => BungaHostAddress(pref),
          update: (value) => value.value,
        );
  late final _connectToHostAction = ConnectToHostAction(
    fetchingNotifier: _fetchingNotifier,
    tokensNotifier: _serverInfoNotifier,
    hostNotifier: _hostAddressNotifier,
  );

  @override
  void initState() {
    super.initState();

    runAfterBuild(_tryToCreateBungaClient);
  }

  @override
  void dispose() {
    _serverInfoNotifier.dispose();
    _fetchingNotifier.dispose();
    _hostAddressNotifier.dispose();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(child != null);

    final actions = Actions(
      actions: <Type, Action<Intent>>{
        ConnectToHostIntent: _connectToHostAction,
        UploadSubtitleIntent: UploadSubtitleAction(),
        UploadLogIntent: UploadLogAction(),
        DoServerRequestIntent: DoServerRequestAction(),
      },
      child: child!,
    );

    return MultiProvider(
      providers: [
        ValueListenableProvider.value(value: _serverInfoNotifier),
        ValueListenableProvider.value(value: _fetchingNotifier),
        ValueListenableProvider.value(value: _hostAddressNotifier),
      ],
      child: actions,
    );
  }

  void _tryToCreateBungaClient() async {
    final bungaHost = _hostAddressNotifier.value.value;
    if (bungaHost.isEmpty) return;
    _connectToHostAction.invoke(ConnectToHostIntent(bungaHost), context);
  }
}

Future<JsonMap> _retryIfTokenExpired({
  required ChannelTokens serverInfo,
  required Future<http.Response> Function(Map<String, String> headers)
  doRequest,
}) async {
  final response = await doRequest({
    'Authorization': 'Bearer ${serverInfo.token.access}',
    'Content-Type': 'application/json',
  });

  if (response.isSuccess) {
    final body = response.body;
    if (body.isEmpty) return {};
    return jsonDecode(body);
  }
  if (jsonDecode(response.body)['code'] == 'token_expired') {
    await serverInfo.refreshToken();
    return _retryIfTokenExpired(serverInfo: serverInfo, doRequest: doRequest);
  } else {
    throw Exception('Bunga request failed: ${response.body}');
  }
}
