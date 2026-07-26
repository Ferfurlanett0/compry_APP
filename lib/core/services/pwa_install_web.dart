import 'dart:js_util' as js_util;
import 'dart:html' as html;

/// Detecta se o usuário está em um dispositivo iOS (iPhone/iPad/iPod)
/// independente do navegador (Safari, Chrome, Firefox, Edge, etc.)
bool _isIOSDevice() {
  try {
    final ua = html.window.navigator.userAgent.toLowerCase();
    return ua.contains('iphone') ||
        ua.contains('ipad') ||
        ua.contains('ipod');
  } catch (_) {
    return false;
  }
}

bool tryInstallImpl() {
  // No iOS (qualquer navegador: Safari, Chrome, Firefox, Edge...),
  // a Apple bloqueia a instalação automática por código.
  // Sempre retornamos false para que o guia de instalação seja exibido.
  if (_isIOSDevice()) return false;

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
