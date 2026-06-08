package com.cropcheckup.crop_check_up

import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            APP_METADATA_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAppVersion" -> result.success(appVersionName())
                else -> result.notImplemented()
            }
        }
    }

    private fun appVersionName(): String {
        val packageInfo =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.getPackageInfo(
                    packageName,
                    PackageManager.PackageInfoFlags.of(0)
                )
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(packageName, 0)
            }

        return packageInfo.versionName ?: ""
    }

    private companion object {
        const val APP_METADATA_CHANNEL = "crop_check_up/app_metadata"
    }
}
