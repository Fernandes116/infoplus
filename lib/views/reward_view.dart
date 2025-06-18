import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reward_provider.dart';
import '../providers/points_provider.dart';
import '../providers/auth_provider.dart';
import '../models/reward.dart';

class RewardView extends StatefulWidget {
  const RewardView({super.key});

  @override
  State<RewardView> createState() => _RewardViewState();
}

class _RewardViewState extends State<RewardView> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    final rewardProvider = context.read<RewardProvider>();
    final pointsProvider = context.read<PointsProvider>();

    if (auth.firebaseUser != null) {
      await rewardProvider.loadRewards();
      await rewardProvider.loadUserRedemptions(auth.firebaseUser!.uid);
      
      final points = await pointsProvider.getUserTotalPoints(auth.firebaseUser!.uid);
      rewardProvider.setUserPoints(points);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rewardProvider = context.watch<RewardProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Resgatar Pontos')),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Seus Pontos:',
                      style: TextStyle(fontSize: 18)),
                  Text('${rewardProvider.userPoints}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: rewardProvider.rewards.length,
              itemBuilder: (context, index) {
                final reward = rewardProvider.rewards[index];
                return _buildRewardCard(reward, auth.firebaseUser?.uid ?? '');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(Reward reward, String userId) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(_getRewardIcon(reward.type)),
        title: Text(reward.name),
        subtitle: Text(reward.description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${reward.pointsRequired} pts',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (reward.type == 'data')
              Text('${reward.value} MB'),
            if (reward.type == 'minutes')
              Text('${reward.value} min'),
            if (reward.type == 'sms')
              Text('${reward.value.toInt()} SMS'),
          ],
        ),
        onTap: () => _redeemReward(reward, userId),
      ),
    );
  }

  IconData _getRewardIcon(String type) {
    switch (type) {
      case 'sms':
        return Icons.sms;
      case 'minutes':
        return Icons.phone;
      case 'data':
        return Icons.data_usage;
      default:
        return Icons.card_giftcard;
    }
  }

  Future<void> _redeemReward(Reward reward, String userId) async {
    final rewardProvider = context.read<RewardProvider>();
    final success = await rewardProvider.redeemReward(userId, reward);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pontos insuficientes para resgatar este brinde!')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Brinde resgatado com sucesso! ${reward.name}')),
    );
  }
}
