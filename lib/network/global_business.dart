import 'package:bunga_player/play/service/service.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/utils/business/run_after_build.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'service.dart';

class NetworkProxyNotifier extends ValueNotifier<String?> {
  NetworkProxyNotifier() : super(null) {
    bindPreference<String>(
      key: 'proxy',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

class ProxyCommunicationNotifier extends ValueNotifier<bool> {
  ProxyCommunicationNotifier() : super(false) {
    bindPreference<bool>(
      key: 'proxy_communication',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

class ProxyMediaNotifier extends ValueNotifier<bool> {
  ProxyMediaNotifier() : super(false) {
    bindPreference<bool>(
      key: 'proxy_media',
      load: (pref) => pref,
      update: (value) => value,
    );
  }
}

class NetworkGlobalBusiness extends SingleChildStatefulWidget {
  const NetworkGlobalBusiness({super.key, super.child});

  @override
  State<NetworkGlobalBusiness> createState() => _NetworkGlobalBusinessState();
}

class _NetworkGlobalBusinessState
    extends SingleChildState<NetworkGlobalBusiness> {
  final _proxy = NetworkProxyNotifier(),
      _enableCommunication = ProxyCommunicationNotifier(),
      _enableMedia = ProxyMediaNotifier();

  @override
  void initState() {
    super.initState();

    runAfterBuild(() {
      Listenable.merge([
        _proxy,
        _enableCommunication,
        _enableMedia,
      ]).addListener(_updateProxy);
      _updateProxy();
    });
  }

  @override
  void dispose() {
    _proxy.dispose();
    _enableCommunication.dispose();
    _enableMedia.dispose();
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _proxy),
        ChangeNotifierProvider.value(value: _enableCommunication),
        ChangeNotifierProvider.value(value: _enableMedia),
      ],
      child: child,
    );
  }

  void _updateProxy() {
    getIt<NetworkService>().setProxy(
      _enableCommunication.value ? _proxy.value : null,
    );
    getIt<MediaPlayer>().proxyNotifier.value = _enableMedia.value
        ? _proxy.value
        : null;
  }
}
