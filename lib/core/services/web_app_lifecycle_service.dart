import 'web_app_lifecycle_stub.dart'
    if (dart.library.html) 'web_app_lifecycle_web.dart';

class WebAppLifecycleService {
  const WebAppLifecycleService._();

  static void markAppReady() {
    markAppReadyImpl();
  }

  static void recordEvent(String name) {
    recordWebEventImpl(name);
  }
}
