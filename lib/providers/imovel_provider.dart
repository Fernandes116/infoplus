import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';
import '../models/imovel.dart';
import '../utils/history_storage.dart';

class ImovelProvider with ChangeNotifier {
  final FirestoreService _firestore;
  List<Imovel> _imoveis = [];

  ImovelProvider(this._firestore);

  List<Imovel> get imoveis => _imoveis;

  List<Imovel> imoveisByProvincia(String provincia) =>
      _imoveis.where((imovel) => imovel.provincia == provincia).toList();

  Future<void> fetchImoveis(String provincia) async {
    final now = DateTime.now();
    final key = 'imoveis_$provincia';
    
    // Lógica de histórico/pagamento
    final history = await HistoryStorage.load(key);
    List<String> shownIds = List<String>.from(history['ids']);
    
    final allImoveis = await _firestore.getImoveis(provincia);
    final novosImoveis = allImoveis.where((imovel) => !shownIds.contains(imovel.id)).toList()
      ..shuffle();

    _imoveis = novosImoveis.take(6).toList(); // Mostra 6 imóveis

    final updatedIds = [...shownIds, ..._imoveis.map((i) => i.id)];
    await HistoryStorage.save(key, updatedIds, now.toIso8601String());

    notifyListeners();
  }

  Future<void> addImovel(Imovel imovel) async {
    await _firestore.addImovel(imovel);
    _imoveis.add(imovel);
    notifyListeners();
  }

  Future<void> deleteImovel(String id) async {
    await _firestore.deleteImovel(id);
    _imoveis.removeWhere((imovel) => imovel.id == id);
    notifyListeners();
  }
}