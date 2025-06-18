import 'package:flutter/foundation.dart';
import '../models/reward.dart';
import '../models/reward_redemption.dart';
import '../services/firestore_service.dart';

class RewardProvider with ChangeNotifier {
  final FirestoreService _firestore;
  List<Reward> _rewards = [];
  List<RewardRedemption> _userRedemptions = [];
  int _userPoints = 0;

  RewardProvider(this._firestore);

  List<Reward> get rewards => _rewards;
  List<RewardRedemption> get userRedemptions => _userRedemptions;
  int get userPoints => _userPoints;

  Future<void> loadRewards() async {
    _rewards = await _firestore.getRewards();
    notifyListeners();
  }

  Future<void> loadUserRedemptions(String userId) async {
    _userRedemptions = await _firestore.getUserRedemptions(userId);
    notifyListeners();
  }

  Future<void> setUserPoints(int points) {
    _userPoints = points;
    notifyListeners();
    return Future.value();
  }

  Future<bool> redeemReward(String userId, Reward reward) async {
    if (_userPoints < reward.pointsRequired) return false;

    final redemption = RewardRedemption(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      rewardId: reward.id,
      redeemedAt: DateTime.now(),
    );

    await _firestore.addRedemption(redemption);
    _userRedemptions.add(redemption);
    _userPoints -= reward.pointsRequired;
    notifyListeners();
    
    return true;
  }
}
