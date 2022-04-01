package com.ydevs.senboo
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    private val BATTERY_CHANNEL = "sample.flutter.dev/battery"
    private lateinit var channel: MethodChannel

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_CHANNEL)
        channel.setMethodCallHandler {call, result ->
            if (call.method == "getBatteryLevel") {
                val arguments = call.arguments() as Map<String, String> 
                val name = arguments["name"]
            }
        }
    }
}
