package com.ussd.infoplus

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log

class MpesaPaymentService : Service() {

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val paymentData = intent?.getStringExtra("payment_data")
        Log.d("MpesaPaymentService", "Processando pagamento: $paymentData")

        // Aqui você pode implementar lógica de pagamento Mpesa
        // - Gerar código USSD Mpesa
        // - Enviar notificação de status
        // - Fazer validações, etc.

        stopSelf()
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        // Serviço não vinculável
        return null
    }
}