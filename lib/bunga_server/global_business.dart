import 'dart:convert';

import 'package:bunga_player/bunga_server/models/bunga_server_info.dart';
import 'package:bunga_player/chat/models/user.dart';
import 'package:bunga_player/client_info/models/client_account.dart';
import 'package:bunga_player/console/service.dart';
import 'package:bunga_player/play/models/play_payload.dart';
import 'package:bunga_player/play/models/video_record.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/utils/business/run_after_build.dart';
import 'package:bunga_player/utils/extensions/http_response.dart';
import 'package:bunga_player/utils/typedef.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class FetchingBungaClient {
  final bool value;
  const FetchingBungaClient(this.value);
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
  final ValueNotifier<FetchingBungaClient> fetchingNotifier;
  final ValueNotifier<BungaServerInfo?> infoNotifier;
  final ValueNotifier<BungaHostAddress> hostNotifier;

  ConnectToHostAction({
    required this.fetchingNotifier,
    required this.infoNotifier,
    required this.hostNotifier,
  });

  @override
  Future<void> invoke(
    ConnectToHostIntent intent, [
    BuildContext? context,
  ]) async {
    final read = context!.read;
    final account = read<ClientAccount>();

    late final http.Response response;
    try {
      fetchingNotifier.value = FetchingBungaClient(true);
      final registerUrl = Uri.parse(intent.url);
      response = await http.post(registerUrl, body: account.toJson());
      if (!response.isSuccess) {
        throw Exception('Login failed: ${response.body}');
      }

      final responseData = jsonDecode(response.body);
      infoNotifier.value = BungaServerInfo.fromJson({
        ...responseData,
        'origin': registerUrl.origin,
      });

      hostNotifier.value = BungaHostAddress(intent.url);
    } finally {
      fetchingNotifier.value = FetchingBungaClient(false);
    }
  }
}

Future<JsonMap> _retryIfTokenExpired({
  required BungaServerInfo serverInfo,
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

// TODO: useless
class AlohaIntent extends Intent {
  const AlohaIntent();
}

typedef AlohaResponse = ({User user, VideoRecord videoRecord});

class AlohaAction extends ContextAction<AlohaIntent> {
  @override
  Future<AlohaResponse?> invoke(
    AlohaIntent intent, [
    BuildContext? context,
  ]) async {
    assert(context != null);
    final read = context!.read;

    final serverInfo = read<BungaServerInfo>();
    final url = serverInfo.origin.replace(
      pathSegments: ['api', 'channels', serverInfo.channel.id, 'aloha', ''],
    );

    final json = await _retryIfTokenExpired(
      serverInfo: serverInfo,
      doRequest: (headers) => http.post(
        url,
        headers: headers,
        body: jsonEncode(User.fromContext(context).toJson()),
      ),
    );
    final projectionJson = json['current_projection'];
    return projectionJson != null
        ? (
            user: User.fromJson(projectionJson['sharer']),
            videoRecord: VideoRecord.fromJson(projectionJson['video_record']),
          )
        : null;
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
    final serverInfo = read<BungaServerInfo>();
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

// TODO: useless
class ProjectIntent extends Intent {
  final VideoRecord videoRecord;
  const ProjectIntent(this.videoRecord);
}

class ProjectAction extends ContextAction<ProjectIntent> {
  @override
  Future<void> invoke(ProjectIntent intent, [BuildContext? context]) async {
    assert(context != null);
    final read = context!.read;
    final serverInfo = read<BungaServerInfo>();
    final url = serverInfo.origin.replace(
      pathSegments: ['api', 'channels', serverInfo.channel.id, 'project', ''],
    );

    try {
      await _retryIfTokenExpired(
        serverInfo: serverInfo,
        doRequest: (headers) => http.post(
          url,
          headers: headers,
          body: jsonEncode(intent.videoRecord.toJson()),
        ),
      );
    } catch (e) {
      throw Exception('Projection failed: $e');
    }
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
  final _serverInfoNotifier = ValueNotifier<BungaServerInfo?>(null)
    ..watchInConsole('Bunga Server Info');
  final _fetchingNotifier = ValueNotifier<FetchingBungaClient>(
    FetchingBungaClient(false),
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
    infoNotifier: _serverInfoNotifier,
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
        AlohaIntent: AlohaAction(),
        UploadSubtitleIntent: UploadSubtitleAction(),
        ProjectIntent: ProjectAction(),
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
