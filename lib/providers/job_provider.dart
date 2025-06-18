import 'package:flutter/foundation.dart';
import '../models/job.dart';
import '../services/firestore_service.dart';
import '../utils/history_storage.dart';

class JobProvider with ChangeNotifier {
  final FirestoreService _firestore;
  List<Job> _jobs = [];

  JobProvider(this._firestore);

  List<Job> get jobs => _jobs;

  List<Job> jobsByProvince(String province) =>
      _jobs.where((job) => job.province == province).toList();

  Future<void> fetchJobs(String province) async {
    final now = DateTime.now();
    final key = 'jobs_$province';
    final history = await HistoryStorage.load(key);

    List<String> shownIds = List<String>.from(history['ids']);
    final lastTime = history['timestamp'] != null
        ? DateTime.tryParse(history['timestamp'])
        : null;

    // Resetar histórico se passaram 24h
    if (lastTime == null || now.difference(lastTime).inHours >= 24) {
      shownIds = [];
    }

    final allJobs = await _firestore.getJobs(province);
    final fresh = allJobs.where((job) => !shownIds.contains(job.id)).toList()
      ..shuffle();

    _jobs = fresh.take(5).toList();

    final updatedIds = [...shownIds, ..._jobs.map((j) => j.id)];
    await HistoryStorage.save(key, updatedIds, now.toIso8601String());

    notifyListeners();
  }

  Future<void> addJob(Job job) async {
    await _firestore.addJob(job);
    _jobs.add(job);
    notifyListeners();
  }

  Future<void> deleteJob(String id) async {
    await _firestore.deleteJob(id);
    _jobs.removeWhere((job) => job.id == id);
    notifyListeners();
  }
}