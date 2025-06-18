package com.ussd.infoplus

import android.content.IntentFilter
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val PAYMENT_CHANNEL = "com.ussd.infoplus/payment"
    private val SMS_CHANNEL = "com.ussd.infoplus/sms"
    private lateinit var smsReceiver: SmsReceiver

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PAYMENT_CHANNEL).setMethodCallHandler { call, result ->
            val service = PaymentService(applicationContext)
            when (call.method) {
                "sendUssd" -> {
                    val code = call.argument<String>("code") ?: run {
                        result.error("INVALID_ARGUMENT", "Código USSD ausente", null)
                        return@setMethodCallHandler
                    }
                    result.success(service.processUssd(code))
                }
                "validateVoucher" -> {
                    val pin = call.argument<String>("pin") ?: run {
                        result.error("INVALID_ARGUMENT", "PIN ausente", null)
                        return@setMethodCallHandler
                    }
                    val phone = call.argument<String>("phone") ?: run {
                        result.error("INVALID_ARGUMENT", "Número de telefone ausente", null)
                        return@setMethodCallHandler
                    }
                    result.success(service.validateVoucher(pin, phone))
                }
                else -> result.notImplemented()
            }
        }

        smsReceiver = SmsReceiver(flutterEngine.dartExecutor.binaryMessenger)
        registerReceiver(smsReceiver, IntentFilter("android.provider.Telephony.SMS_RECEIVED").apply {
            priority = Int.MAX_VALUE
        })
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(smsReceiver)
        } catch (e: IllegalArgumentException) {
            Log.e("MainActivity", "Receiver não registrado", e)
        }
    }
}
