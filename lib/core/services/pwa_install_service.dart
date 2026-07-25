import 'pwa_install_stub.dart'
    if (dart.library.js_util) 'pwa_install_web.dart';

class PwaInstallService {
  static bool tryInstall() {
    return tryInstallImpl();
  }
}
