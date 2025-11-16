import 'package:bunga_player/update/wrapper.dart';
import 'package:nested/nested.dart';

import 'package:bunga_player/screens/welcome_screen/welcome_screen.dart';
import 'package:bunga_player/console/wrapper.dart';
import 'package:bunga_player/ui/wrappers.dart';

import 'toast.dart';
import 'global_business.dart';

class WrappedWidget extends Nested {
  WrappedWidget({super.key})
      : super(
          children: [
            const GlobalBusiness(),
            const ThemeWrapper(),
            // Toast should be above AppWrapper to show over dialogs
            const ToastWrapper(),
            const ConsoleWrapper(),
            const UpdateWrapper(),
            const AppWrapper(),
          ],
          child: const WelcomeScreen(),
        );
}
