import 'package:json_annotation/json_annotation.dart';

part 'reward_redemption.g.dart';

@JsonSerializable()
class RewardRedemption {
  final String id;
  final String userId;
  final String rewardId;
  final DateTime redeemedAt;
  final bool isProcessed;

  RewardRedemption({
    required this.id,
    required this.userId,
    required this.rewardId,
    required this.redeemedAt,
    this.isProcessed = false,
  });

  factory RewardRedemption.fromJson(Map<String, dynamic> json) => 
      _$RewardRedemptionFromJson(json);
  Map<String, dynamic> toJson() => _$RewardRedemptionToJson(this);
}
