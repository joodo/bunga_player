import 'package:bunga_player/models/chat/user.dart';
import 'package:bunga_player/providers/chat.dart';
import 'package:bunga_player/providers/ui/ui.dart';
import 'package:bunga_player/services/bunga.dart';
import 'package:bunga_player/services/preferences.dart';
import 'package:bunga_player/services/services.dart';
import 'package:bunga_player/services/stream_io.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RenameCurrentUserIntent extends Intent {
  final String newName;

  const RenameCurrentUserIntent(this.newName);
}

class RenameCurrentUserAction extends ContextAction<RenameCurrentUserIntent> {
  @override
  Future<void> invoke(RenameCurrentUserIntent intent,
      [BuildContext? context]) async {
    final currentUser = context!.read<CurrentUser>();
    final isAwake = context.read<IsCatAwake>();

    if (currentUser.value != null) {
      final oldUser = currentUser.value!;
      currentUser.value = User(id: oldUser.id, name: intent.newName);
      await getService<StreamIO>()
          .renameUser(currentUser.value!, intent.newName);
    }

    await getService<Preferences>().set('user_name', intent.newName);

    isAwake.value = true;
  }

  @override
  bool isEnabled(RenameCurrentUserIntent intent, [BuildContext? context]) {
    assert(context != null, 'Action need context to set current user provider');
    return true;
  }
}

Future<void> login(User user) async {
  // Get token by client id from bunga
  final bunga = getService<Bunga>();
  final token = await bunga.userLogin(user.id);

  // Login to stream server
  final chatService = getService<StreamIO>();
  await chatService.login(user.id, token, user.name);
}

class AutoLoginIntent extends Intent {}

class AutoLoginAction extends ContextAction<AutoLoginIntent> {
  @override
  Future<void> invoke(AutoLoginIntent intent, [BuildContext? context]) async {
    final isAwake = context!.read<IsCatAwake>();

    final currentUser = context.read<CurrentUser>();

    // Get user name and id from preference
    final pref = getService<Preferences>();
    final name = pref.get<String>('user_name')!;
    String? clientId = pref.get<String>('client_id');
    if (clientId == null) {
      clientId = const Uuid().v4();
      pref.set('client_id', clientId);
    }

    final user = User(id: clientId, name: name);
    currentUser.value = user;

    await login(user);

    isAwake.value = true;
  }

  @override
  bool isEnabled(AutoLoginIntent intent, [BuildContext? context]) {
    assert(context != null, 'Action need context to set current user provider');
    final pref = getService<Preferences>();
    final name = pref.get<String>('user_name');
    return name != null;
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
    final isAwake = context!.read<IsCatAwake>();
    isAwake.value = false;

    final currentUser = context.read<CurrentUser>();
    final newUser = User(id: intent.newId, name: currentUser.value!.name);
    currentUser.value = newUser;

    final chatService = getService<StreamIO>();
    await chatService.logout();

    await login(newUser);

    isAwake.value = true;
  }

  @override
  bool isEnabled(ChangeCurrentUserIdIntent intent, [BuildContext? context]) {
    assert(context != null, 'Action need context to set current user provider');
    return context!.read<CurrentUser>().value != null;
  }
}

final bindings = <Type, Action<Intent>>{
  RenameCurrentUserIntent: RenameCurrentUserAction(),
  AutoLoginIntent: AutoLoginAction(),
  ChangeCurrentUserIdIntent: ChangeCurrentUserIdAction(),
};
