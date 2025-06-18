import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/job.dart';
import '../models/price.dart';
import '../models/imovel.dart';
import '../models/consulta_historico.dart';
import '../models/points_record.dart';
import '../models/reward.dart';
import '../models/reward_redemption.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get firebaseUser => FirebaseAuth.instance.currentUser;

  // ============ Jobs Operations ============
  Future<List<Job>> getJobs(String province) async {
    final snapshot = await _firestore
        .collection('jobs')
        .where('province', isEqualTo: province)
        .get();
    return snapshot.docs.map((doc) => Job.fromJson(doc.data())).toList();
  }

  Future<void> addJob(Job job) async {
    await _firestore.collection('jobs').doc(job.id).set(job.toJson());
  }

  Future<void> deleteJob(String id) async {
    await _firestore.collection('jobs').doc(id).delete();
  }

  // ============ Prices Operations ============
  Future<List<Price>> getPrices(String province) async {
    final snapshot = await _firestore
        .collection('prices')
        .where('province', isEqualTo: province)
        .get();
    return snapshot.docs.map((doc) => Price.fromJson(doc.data())).toList();
  }

  Future<void> addPrice(Price price) async {
    await _firestore.collection('prices').doc(price.id).set(price.toJson());
  }

  Future<void> deletePrice(String id) async {
    await _firestore.collection('prices').doc(id).delete();
  }

  // ============ Imóveis Operations ============
  Future<List<Imovel>> getImoveis(String provincia) async {
    final snapshot = await _firestore
        .collection('imoveis')
        .where('provincia', isEqualTo: provincia)
        .get();
    return snapshot.docs.map((doc) => Imovel.fromJson(doc.data())).toList();
  }

  Future<void> addImovel(Imovel imovel) async {
    await _firestore.collection('imoveis').doc(imovel.id).set(imovel.toJson());
  }

  Future<void> deleteImovel(String id) async {
    await _firestore.collection('imoveis').doc(id).delete();
  }

  // ============ Consultas Operations ============
  Future<List<ConsultaHistorico>> getUserConsultas(String userId) async {
    final snapshot = await _firestore
        .collection('consultas')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => ConsultaHistorico.fromJson(doc.data())).toList();
  }

  Future<void> addConsulta(ConsultaHistorico consulta) async {
    await _firestore.collection('consultas').doc(consulta.id).set(consulta.toJson());
  }

  // ============ Points Operations ============
  Future<List<PointsRecord>> getUserPoints(String userId) async {
    final snapshot = await _firestore
        .collection('points')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => PointsRecord.fromJson(doc.data())).toList();
  }

  Future<void> addPointsRecord(PointsRecord record) async {
    await _firestore.collection('points').doc().set(record.toJson());
  }

  Future<int> getUserTotalPoints(String userId) async {
    final snapshot = await _firestore
        .collection('points')
        .where('userId', isEqualTo: userId)
        .get();
    
    int total = 0;
    for (final doc in snapshot.docs) {
      total += (doc.data()['points'] as int? ?? 0);
    }
    return total;
  }

  // ============ Rewards Operations ============
  Future<List<Reward>> getRewards() async {
    final snapshot = await _firestore.collection('rewards').get();
    return snapshot.docs.map((doc) => Reward.fromJson(doc.data())).toList();
  }

  Future<List<RewardRedemption>> getUserRedemptions(String userId) async {
    final snapshot = await _firestore
        .collection('redemptions')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => RewardRedemption.fromJson(doc.data())).toList();
  }

  Future<void> addRedemption(RewardRedemption redemption) async {
    await _firestore.collection('redemptions').doc(redemption.id).set(redemption.toJson());
  }
}
