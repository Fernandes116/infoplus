import 'package:flutter/foundation.dart';
import '../services/payment_service.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentService _service;
  bool _isLoading = false;
  String? _lastError;
  String? _lastResponse;

  PaymentProvider(this._service);

  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  String? get lastResponse => _lastResponse;

  Future<bool> pay(double amount, String phone) async {
    _isLoading = true;
    _lastError = null;
    _lastResponse = null;
    notifyListeners();

    try {
      _lastResponse = await _service.pay(amount, phone);
      return true;
    } catch (e) {
      _lastError = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> validateVoucher(String pin) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final isValid = await _service.validateVoucher(pin);
      _lastResponse = isValid ? 'Voucher válido' : 'Voucher inválido';
      return isValid;
    } catch (e) {
      _lastError = 'Erro na validação: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
