import 'dart:js_util' as js_util;

void markAppReadyImpl() {
  try {
    if (js_util.hasProperty(js_util.globalThis, 'compryAppReady')) {
      js_util.callMethod<void>(js_util.globalThis, 'compryAppReady', const []);
    }
  } catch (_) {
    // The web shell is optional on non-standard web hosts.
  }
}

void recordWebEventImpl(String name) {
  try {
    if (js_util.hasProperty(js_util.globalThis, 'compryPwaDiagnostic')) {
      js_util.callMethod<void>(
        js_util.globalThis,
        'compryPwaDiagnostic',
        [name],
      );
    }
  } catch (_) {
    // Diagnostics must never affect app startup.
  }
}
