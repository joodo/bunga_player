import 'package:nested/nested.dart';

import '../main_screen.dart';
import 'app.dart';
import 'console.dart';
import 'theme.dart';
import 'update_and_clean.dart';
import 'restart.dart';
import 'toast.dart';
import 'actions.dart';
import 'providers.dart';

class WrappedWidget extends Nested {
  WrappedWidget({super.key})
      : super(
          children: [
            const RestartWrapper(),
            const ProvidersWrapper(),
            const ThemeWrapper(),
            const ToastWrapper(),
            const AppWrapper(),
            const ActionsWrapper(),
            const UpdateAndCleanWrapper(),
            const Console(),
          ],
          child: const MainScreen(),
        );
}
