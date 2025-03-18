package com.sirmaur.citybuddy  // Ensure this matches your actual package name

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.sirmaur.citybuddy/maps"  // Unique channel for communication

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "pickLocation") {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("geo:0,0?q=Select Location"))
                startActivity(intent)
                result.success("Opened Maps")
            } else {
                result.notImplemented()
            }
        }
    }
}
