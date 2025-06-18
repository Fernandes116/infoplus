package com.ussd.infoplus

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.telephony.SmsMessage
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import java.text.SimpleDateFormat
import java.util.*

class SmsReceiver(private val messenger: BinaryMessenger) : BroadcastReceiver() {
    private val channel = "com.ussd.infoplus/sms"
    private val dateFormat = SimpleDateFormat("HH:mm:ss dd/MM/yyyy", Locale.getDefault())

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        val pdus = intent.extras?.get("pdus") as? Array<*> ?: return
        val messages = pdus.mapNotNull { pdu ->
            SmsMessage.createFromPdu(pdu as ByteArray)?.run {
                mapOf(
                    "sender" to originatingAddress,
                    "body" to messageBody,
                    "timestamp" to System.currentTimeMillis()
                )
            }
        }

        messages.forEach { msg ->
            val parsed = parsePaymentSms(msg["body"].toString())
            if (parsed.isNotEmpty()) {
                MethodChannel(messenger, channel).invokeMethod(
                    "paymentNotification",
                    parsed + mapOf("sender" to msg["sender"], "raw" to msg["body"])
                )
            }
        }
    }

    private fun parsePaymentSms(message: String): Map<String, Any> {
        return when {
            message.contains("Efectuaste o pagamento") -> parseMpesaSms(message)
            message.contains("Pagamento efectuado com sucesso") -> parseEmolaSms(message)
            else -> emptyMap()
        }
    }

    private fun parseMpesaSms(message: String): Map<String, Any> {
        val regex = Regex("""(\d+\.?\d*) MT.*ID da transacao: (\S+).*Saldo: (\d+\.?\d*) MT""")
        val match = regex.find(message) ?: return emptyMap()
        return mapOf(
            "amount" to match.groupValues[1].toDouble(),
            "transactionId" to match.groupValues[2],
            "balance" to match.groupValues[3].toDouble(),
            "operator" to "M-Pesa"
        )
    }

    private fun parseEmolaSms(message: String): Map<String, Any> {
        val regex = Regex("""Valor: (\d+\.?\d*) MT.*ID: (\S+).*Saldo: (\d+\.?\d*) MT""")
        val match = regex.find(message) ?: return emptyMap()
        return mapOf(
            "amount" to match.groupValues[1].toDouble(),
            "transactionId" to match.groupValues[2],
            "balance" to match.groupValues[3].toDouble(),
            "operator" to "E-Mola"
        )
    }
}