import 'dart:js_util' as js_util;

bool tryInstallImpl() {
  try {
    if (js_util.hasProperty(js_util.globalThis, 'triggerPwaInstall')) {
      final result = js_util.callMethod(js_util.globalThis, 'triggerPwaInstall', []);
      return result == true;
    }
  } catch (e) {
    // Ignore js errors
  }
  return false;
}
