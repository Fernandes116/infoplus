package com.ussd.infoplus

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

class UssdExecutorService : Service() {
    private val channelId = "ussd_payments"
    private val notificationId = 101

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val code = intent?.getStringExtra("code") ?: run {
            stopSelf()
            return START_NOT_STICKY
        }

        val simSlot = intent.getIntExtra("slot", 0) // Slot dinâmico (0 = SIM1, 1 = SIM2)

        createNotificationChannel()
        startForeground(notificationId, buildNotification("Processando pagamento..."))

        try {
            val ussdFormatted = code.replace("#", Uri.encode("#"))
            val dialIntent = Intent(Intent.ACTION_CALL).apply {
                data = Uri.parse("tel:$ussdFormatted")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

                // Envia os extras comuns para selecionar o SIM correto (varia por fabricante)
                putExtra("com.android.phone.extra.slot", simSlot)
                putExtra("simSlot", simSlot)
                putExtra("slot", simSlot)
                putExtra("subscription", simSlot)
                putExtra("android.telecom.extra.PHONE_ACCOUNT_HANDLE", simSlot)
            }

            startActivity(dialIntent)
            Log.d("USSD", "Código discado: $code no slot $simSlot")
        } catch (e: Exception) {
            Log.e("USSD", "Falha na discagem", e)
            handleFallback(code)
        }

        stopSelf()
        return START_NOT_STICKY
    }

    private fun handleFallback(code: String) {
        try {
            val clipboard = getSystemService(CLIPBOARD_SERVICE) as android.content.ClipboardManager
            val clip = android.content.ClipData.newPlainText("USSD Code", code)
            clipboard.setPrimaryClip(clip)

            val notification = NotificationCompat.Builder(this, channelId)
                .setContentTitle("Código USSD copiado")
                .setContentText("Cole no discador: $code")
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .build()

            (getSystemService(NOTIFICATION_SERVICE) as NotificationManager)
                .notify(notificationId + 1, notification)
        } catch (e: Exception) {
            Log.e("USSD", "Falha no fallback", e)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Pagamentos USSD",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Status de pagamentos via USSD"
            }

            (getSystemService(NotificationManager::class.java)).createNotificationChannel(channel)
        }
    }

    private fun buildNotification(message: String) = NotificationCompat.Builder(this, channelId)
        .setContentTitle("Infoplus Pagamentos")
        .setContentText(message)
        .setSmallIcon(android.R.drawable.ic_dialog_info)
        .setPriority(NotificationCompat.PRIORITY_LOW)
        .setOngoing(true)
        .build()

    override fun onBind(intent: Intent?): IBinder? = null
}