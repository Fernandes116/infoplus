import 'package:flutter/foundation.dart';
import '../models/price.dart';
import '../services/firestore_service.dart';
import '../utils/history_storage.dart';

class PriceProvider with ChangeNotifier {
  final FirestoreService _firestore;
  List<Price> _prices = [];

  PriceProvider(this._firestore);

  List<Price> get prices => _prices;

  List<Price> pricesByProvince(String province) =>
      _prices.where((price) => price.province == province).toList();

  Future<void> fetchPrices(String province) async {
    final now = DateTime.now();
    final key = 'prices_$province';
    final history = await HistoryStorage.load(key);

    List<String> shownIds = List<String>.from(history['ids']);
    final lastTime = history['timestamp'] != null
        ? DateTime.tryParse(history['timestamp'])
        : null;

    // Resetar histórico se passaram 24h
    if (lastTime == null || now.difference(lastTime).inHours >= 24) {
      shownIds = [];
    }

    final allPrices = await _firestore.getPrices(province);
    final fresh = allPrices.where((price) => !shownIds.contains(price.id)).toList()
      ..shuffle();

    _prices = fresh.take(8).toList();

    final updatedIds = [...shownIds, ..._prices.map((p) => p.id)];
    await HistoryStorage.save(key, updatedIds, now.toIso8601String());

    notifyListeners();
  }

  Future<void> addPrice(Price price) async {
    await _firestore.addPrice(price);
    _prices.add(price);
    notifyListeners();
  }

  Future<void> deletePrice(String id) async {
    await _firestore.deletePrice(id);
    _prices.removeWhere((price) => price.id == id);
    notifyListeners();
  }
}