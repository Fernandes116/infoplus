import 'dart:async';
import 'package:flutter/services.dart';
import '../config/env.dart';

class PaymentService {
  static const _channel = MethodChannel('com.ussd.infoplus/payment');
  static const _smsChannel = MethodChannel('com.ussd.infoplus/sms');
  static final _paymentStreamController = StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get paymentStream => _paymentStreamController.stream;

  PaymentService() {
    _smsChannel.setMethodCallHandler((call) async {
      if (call.method == 'paymentNotification') {
        _paymentStreamController.add(Map<String, dynamic>.from(call.arguments));
      }
      return null;
    });
  }

  Future<String> pay(double amount, String phone) async {
    try {
      final digits = phone.replaceAll(RegExp(r'\D'), '');
      final local = digits.startsWith('258') ? digits.substring(3) : digits;
      if (local.length < 9) throw Exception('Número inválido (deve ter 9 dígitos)');

      final prefix = local.substring(0, 2);
      final isMpesa = prefix == '84' || prefix == '85';
      final isEmola = prefix == '86' || prefix == '87';

      if (!isMpesa && !isEmola) throw Exception('Operadora não suportada: $prefix');

      final ussdCode = _generateUssdCode(
        isMpesa: isMpesa,
        amount: amount,
        merchantCode: isMpesa ? Env.mpesaMerchantCode : Env.emolaMerchantCode,
        serviceCode: isMpesa ? null : Env.emolaServiceCode,
      );

      final result = await _channel.invokeMethod<String>('sendUssd', {
        'code': ussdCode,
        'operator': isMpesa ? 'M-Pesa' : 'E-Mola',
      }).timeout(const Duration(seconds: 30));

      return result ?? 'Pagamento iniciado via USSD';
    } on PlatformException catch (e) {
      throw Exception('Erro na plataforma: ${e.message}');
    } on TimeoutException {
      throw Exception('Tempo excedido - sem resposta do USSD');
    } catch (e) {
      throw Exception('Falha no pagamento: ${e.toString()}');
    }
  }

  Future<bool> validateVoucher(String pin) async {
    try {
      // Implementação real seria com chamada à API ou banco de dados
      final isValid = await _channel.invokeMethod<bool>('validateVoucher', {'pin': pin});
      return isValid ?? false;
    } on PlatformException catch (e) {
      throw Exception('Erro na validação: ${e.message}');
    }
  }

  String _generateUssdCode({
    required bool isMpesa,
    required double amount,
    required String merchantCode,
    String? serviceCode,
  }) {
    return isMpesa
        ? '*848*$merchantCode*${amount.toStringAsFixed(2)}#'
        : '*848*$merchantCode*${amount.toStringAsFixed(2)}*$serviceCode#';
  }

  void dispose() => _paymentStreamController.close();
}
