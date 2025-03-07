import 'dart:convert';

import 'package:bunga_player/bunga_server/models/bunga_client_info.dart';
import 'package:bunga_player/client_info/models/client_account.dart';
import 'package:bunga_player/utils/business/preference_notifier.dart';
import 'package:bunga_player/utils/business/provider.dart';
import 'package:bunga_player/utils/extensions/http_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

@immutable
class FetchingBungaClient {
  final bool value;
  const FetchingBungaClient(this.value);
}

@immutable
class BungaHostAddress {
  final String value;
  const BungaHostAddress(this.value);
  Uri get uri => Uri.parse(value);
}

@immutable
class ConnectToHostIntent extends Intent {
  final String url;
  const ConnectToHostIntent(this.url);
}

class ConnectToHostAction extends ContextAction<ConnectToHostIntent> {
  final ValueNotifier<bool> fetchingNotifier;
  final ValueNotifier<BungaClientInfo?> infoNotifier;
  final ValueNotifier<String> hostNotifier;

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
      fetchingNotifier.value = true;
      response = await http.post(
        Uri.parse(intent.url),
        body: account.toJson(),
      );
      if (!response.isSuccess) {
        throw Exception('Login failed: ${response.body}');
      }

      final responseData = jsonDecode(response.body);
      infoNotifier.value = BungaClientInfo.fromJson(responseData);

      hostNotifier.value = intent.url;
    } finally {
      fetchingNotifier.value = false;
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
  final _infoNotifier = ValueNotifier<BungaClientInfo?>(null);
  final _fetchingNotifier = ValueNotifier<bool>(false);
  final _hostAddressNotifier = createPreferenceNotifier<String>(
    key: 'bunga_host',
    initValue: '',
  );
  late final _connectToHostAction = ConnectToHostAction(
    fetchingNotifier: _fetchingNotifier,
    infoNotifier: _infoNotifier,
    hostNotifier: _hostAddressNotifier,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryToCreateBungaClient();
    });
  }

  @override
  void dispose() {
    _infoNotifier.dispose();
    _fetchingNotifier.dispose();
    _hostAddressNotifier.dispose();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        ValueListenableProvider.value(value: _infoNotifier),
        ValueProxyListenableProvider(
          valueListenable: _fetchingNotifier,
          proxy: (value) => FetchingBungaClient(value),
        ),
        ValueProxyListenableProvider(
          valueListenable: _hostAddressNotifier,
          proxy: (value) => BungaHostAddress(value),
        ),
      ],
      child: Actions(
        actions: <Type, Action<Intent>>{
          ConnectToHostIntent: _connectToHostAction,
        },
        child: child!,
      ),
    );
  }

  void _tryToCreateBungaClient() async {
    final bungaHost = _hostAddressNotifier.value;
    if (bungaHost.isEmpty) return;
    _connectToHostAction.invoke(ConnectToHostIntent(bungaHost), context);
  }
}
