import 'package:flutter/services.dart';

class SmsListener {
  MethodChannel? _channel;

  void startListening({
    required Function(String sender, String fullMessage, Map<String, dynamic> parsedData) onPaymentNotification,
    Function(dynamic error)? onError,
  }) {
    _channel = const MethodChannel('com.ussd.infoplus/sms');
    _channel?.setMethodCallHandler((call) async {
      if (call.method == 'paymentNotification') {
        try {
          final args = call.arguments as Map<dynamic, dynamic>;
          final sender = args['sender'] as String? ?? 'Desconhecido';
          final fullMessage = args['fullMessage'] as String? ?? '';
          final parsedData = Map<String, dynamic>.from(args['parsedData'] as Map? ?? {});
          onPaymentNotification(sender, fullMessage, parsedData);
        } catch (e) {
          onError?.call(e);
        }
      }
      return null;
    });
  }

  void stopListening() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
  }
}
