import 'package:bunga_player/update/wrapper.dart';
import 'package:nested/nested.dart';

import 'package:bunga_player/screens/welcome_screen/welcome_screen.dart';
import 'package:bunga_player/console/wrapper.dart';
import 'package:bunga_player/ui/wrappers.dart';

import 'global_business.dart';

class WrappedWidget extends Nested {
  WrappedWidget({super.key})
    : super(
        children: [
          const GlobalBusiness(),
          const AppWrapper(),
          const ConsoleWrapper(),
          const UpdateWrapper(),
          const NavigatorWrapper(),
        ],
        child: const WelcomeScreen(),
      );
}
