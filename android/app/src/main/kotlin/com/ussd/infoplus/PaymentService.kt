package com.ussd.infoplus

import android.content.Context
import android.content.Intent

class PaymentService(private val context: Context) {
    
    fun processUssd(code: String): String {
        return try {
            val intent = Intent(context, UssdExecutorService::class.java).apply {
                putExtra("code", code)
            }
            context.startService(intent)
            "USSD enviado com sucesso"
        } catch (e: Exception) {
            "Erro ao iniciar serviço: ${e.localizedMessage}"
        }
    }

    fun validateVoucher(pin: String, phone: String): Boolean {
        val digits = phone.replace(Regex("\\D"), "")
        val local = if (digits.startsWith("258")) digits.substring(3) else digits
        
        return when {
            local.startsWith("84") || local.startsWith("85") -> pin.matches(Regex("^\\d{4}$"))
            local.startsWith("86") || local.startsWith("87") -> pin.matches(Regex("^\\d{6}$"))
            else -> false
        }
    }
}
