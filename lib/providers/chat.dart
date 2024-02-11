import 'package:bunga_player/models/chat/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CurrentUser extends ValueNotifier<User?> {
  CurrentUser(super.value);
}

final providers = MultiProvider(providers: [
  ChangeNotifierProvider(create: (context) => CurrentUser(null)),
]);
