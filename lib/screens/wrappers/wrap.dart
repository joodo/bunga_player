import 'package:nested/nested.dart';

import '../welcome_screen.dart';
import 'app.dart';
import 'theme.dart';
import 'update_and_clean.dart';
import 'restart.dart';
import 'toast.dart';
import 'actions.dart';
import 'global_business.dart';

class WrappedWidget extends Nested {
  WrappedWidget({super.key})
      : super(
          children: [
            const RestartWrapper(),
            const GlobalBusiness(),
            const ThemeWrapper(),
            const ToastWrapper(),
            const ActionsWrapper(),
            const AppWrapper(),
            const UpdateAndCleanWrapper(),
          ],
          child: const WelcomeScreen(),
        );
}
