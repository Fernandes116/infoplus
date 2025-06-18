import 'package:flutter/foundation.dart';
import '../models/points_record.dart';
import '../services/firestore_service.dart';

class PointsProvider with ChangeNotifier {
  final FirestoreService _firestore;
  List<PointsRecord> _points = [];
  bool loading = false;

  PointsProvider(this._firestore);

  List<PointsRecord> get points => _points;

  Future<void> addPoints(String userId, int points, String source) async {
    try {
      loading = true;
      notifyListeners();
      final record = PointsRecord(
        userId: userId,
        points: points,
        timestamp: DateTime.now(),
        source: source,
      );
      await _firestore.addPointsRecord(record);
      _points.add(record);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadPoints(String userId) async {
    try {
      loading = true;
      notifyListeners();
      _points = await _firestore.getUserPoints(userId);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserPoints(String userId) async {
    await loadPoints(userId);
  }

  Future<int> getUserTotalPoints(String userId) async {
    try {
      loading = true;
      notifyListeners();
      return await _firestore.getUserTotalPoints(userId);
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
