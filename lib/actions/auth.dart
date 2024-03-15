import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/providers/settings.dart';
import 'package:bunga_player/providers/ui.dart';
import 'package:bunga_player/services/alist.dart';
import 'package:bunga_player/services/bunga.dart';
import 'package:bunga_player/services/online_video.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/chat.dart';
import 'package:bunga_player/actions/dispatcher.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

class AutoLoginIntent extends Intent {}

class AutoLoginAction extends ContextAction<AutoLoginIntent> {
  @override
  Future<void> invoke(AutoLoginIntent intent, [BuildContext? context]) async {
    if (!context!.mounted) return;

    final read = context.read;
    final result = Actions.invoke(
      context,
      LoginIntent(User(
        id: read<SettingClientId>().value,
        name: read<SettingUserName>().value,
      )),
    ) as Future;
    await result;

    // Fetch bilibili sess
    getIt<OnlineVideoService>().fetchSess();
  }

  @override
  bool isEnabled(AutoLoginIntent intent, [BuildContext? context]) {
    assert(context != null, 'Action need context to set current user provider');
    return context!.read<SettingUserName>().value.isNotEmpty;
  }
}

class ChangeCurrentUserIdIntent extends Intent {
  final String newId;
  const ChangeCurrentUserIdIntent(this.newId);
}

class ChangeCurrentUserIdAction
    extends ContextAction<ChangeCurrentUserIdIntent> {
  @override
  Future<void> invoke(
    ChangeCurrentUserIdIntent intent, [
    BuildContext? context,
  ]) async {
    final currentUserName = context!.read<CurrentUser>().value!.name;

    var result = Actions.invoke(context, LogoutIntent()) as Future;
    await result;

    final newUser = User(id: intent.newId, name: currentUserName);

    if (!context.mounted) throw Exception();
    result = Actions.invoke(context, LoginIntent(newUser)) as Future;
    await result;
  }

  @override
  bool isEnabled(ChangeCurrentUserIdIntent intent, [BuildContext? context]) {
    assert(context != null, 'Action need context to set current user provider');
    return context!.read<CurrentUser>().value != null;
  }
}

class LoginIntent extends Intent {
  final User user;
  const LoginIntent(this.user);
}

class LoginAction extends ContextAction<LoginIntent> {
  @override
  Future<void> invoke(LoginIntent intent, [BuildContext? context]) async {
    // Get token by client id from bunga
    final bunga = getIt<Bunga>();
    final token = await bunga.userLogin(intent.user.id);

    // Login to stream server
    final chatService = getIt<ChatService>();
    await chatService.login(intent.user.id, token, intent.user.name);

    if (context!.mounted) context.read<CurrentUser>().value = intent.user;
  }
}

class LogoutIntent extends Intent {}

class LogoutAction extends ContextAction<LogoutIntent> {
  @override
  Future<void> invoke(LogoutIntent intent, [BuildContext? context]) async {
    final currentUser = context!.read<CurrentUser>();

    final chatService = getIt<ChatService>();
    await chatService.logout();

    currentUser.value = null;
  }

  @override
  bool isEnabled(LogoutIntent intent, [BuildContext? context]) {
    return context?.read<CurrentUser>().value != null;
  }
}

class AuthActions extends SingleChildStatefulWidget {
  const AuthActions({super.key, super.child});

  @override
  State<AuthActions> createState() => _AuthActionsState();
}

class _AuthActionsState extends SingleChildState<AuthActions> {
  @override
  void initState() {
    super.initState();

    getIt<AList>()
        .initService()
        .then((_) => context.read<AListInitiated>().value = true);
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Actions(
      dispatcher: LoggingActionDispatcher(prefix: 'Auth'),
      actions: <Type, Action<Intent>>{
        AutoLoginIntent: AutoLoginAction(),
        ChangeCurrentUserIdIntent: ChangeCurrentUserIdAction(),
        LoginIntent: LoginAction(),
        LogoutIntent: LogoutAction(),
      },
      child: child!,
    );
  }
}
