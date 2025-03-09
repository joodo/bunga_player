import 'package:bunga_player/alist/business.dart';
import 'package:bunga_player/console/actions.dart';
import 'package:flutter/material.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';

import 'package:bunga_player/chat/global_business.dart';
import 'package:bunga_player/play/actions.dart';
import 'package:bunga_player/ui/actions.dart';

class ActionsLeaf {
  late BuildContext _leafContext;
  void registerContext(BuildContext context) => _leafContext = context;

  Object? mayBeInvoke(Intent intent) =>
      Actions.maybeInvoke(_leafContext, intent);
  Object? invoke(Intent intent) => Actions.invoke(_leafContext, intent);
  Object? maybeInvoke(Intent intent) =>
      Actions.maybeInvoke(_leafContext, intent);
}

class ActionsWrapper extends SingleChildStatelessWidget {
  const ActionsWrapper({super.key, super.child});

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Nested(
      children: [
        // TODO:remove
        Provider(create: (context) => ActionsLeaf()),
        const UIActions(),
        const PlayActions(),
        const ChatGlobalBusiness(),
        const AListGlobalBusiness(),
        const ConsoleActions(),
        SingleChildBuilder(builder: (context, child) {
          context.read<ActionsLeaf>().registerContext(context);
          return child!;
        }),
      ],
      child: child,
    );
  }
}
