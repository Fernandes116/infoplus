import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/consulta_historico.dart';
import '../services/firestore_service.dart';

class ConsultaHistoricoProvider with ChangeNotifier {
  final FirestoreService _firestore;
  List<ConsultaHistorico> _consultas = [];
  bool loading = false;

  ConsultaHistoricoProvider(this._firestore);

  List<ConsultaHistorico> get consultas => _consultas;

  Future<void> carregarHistorico(String userId) async {
    try {
      loading = true;
      notifyListeners();
      _consultas = await _firestore.getUserConsultas(userId);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHistorico() async {
    try {
      loading = true;
      notifyListeners();
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      _consultas = await _firestore.getUserConsultas(userId);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> salvar(ConsultaHistorico consulta) async {
    try {
      loading = true;
      notifyListeners();
      await _firestore.addConsulta(consulta);
      _consultas.add(consulta);
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
