import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

class AutofillService {
  AutofillService._();

  static const _manualLoginCompletedKey = 'manual_login_completed';
  static const _channel = MethodChannel('com.listapro.lista_pro/autofill');

  static bool get hasCompletedManualLogin =>
      Hive.box(AppConstants.hiveBoxSettings)
          .get(_manualLoginCompletedKey, defaultValue: false) ==
      true;

  static Future<void> configurePlatform() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    await _setAndroidAutofillEnabled(hasCompletedManualLogin);
  }

  static Future<void> markManualLoginCompleted() async {
    await Hive.box(AppConstants.hiveBoxSettings)
        .put(_manualLoginCompletedKey, true);
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _setAndroidAutofillEnabled(true);
    }
  }

  static Future<void> _setAndroidAutofillEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod<void>(
        'setAutofillEnabled',
        <String, Object>{'enabled': enabled},
      );
    } on PlatformException catch (error) {
      debugPrint('Não foi possível configurar o autofill: $error');
    }
  }
}
