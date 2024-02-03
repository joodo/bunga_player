/// FIXME
/// walkthrough for windows
/// https://github.com/dart-lang/http/issues/627
/// https://stackoverflow.com/questions/60587137/conveyor-with-flutter-handshake-error-when-running-net-web-app-locally/61120486#61120486

import 'dart:io';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void sslWalkthrough() {
  HttpOverrides.global = MyHttpOverrides();
}
