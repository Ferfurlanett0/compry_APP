package com.listapro.lista_pro

import android.os.Build
import android.view.View
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val autofillChannel = "com.listapro.lista_pro/autofill"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, autofillChannel)
            .setMethodCallHandler { call, result ->
                if (call.method != "setAutofillEnabled") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val enabled = call.argument<Boolean>("enabled") ?: false
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    window.decorView.importantForAutofill = if (enabled) {
                        View.IMPORTANT_FOR_AUTOFILL_AUTO
                    } else {
                        View.IMPORTANT_FOR_AUTOFILL_NO_EXCLUDE_DESCENDANTS
                    }
                }
                result.success(null)
            }
    }
}
