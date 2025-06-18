// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_redemption.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RewardRedemption _$RewardRedemptionFromJson(Map<String, dynamic> json) =>
    RewardRedemption(
      id: json['id'] as String,
      userId: json['userId'] as String,
      rewardId: json['rewardId'] as String,
      redeemedAt: DateTime.parse(json['redeemedAt'] as String),
      isProcessed: json['isProcessed'] as bool? ?? false,
    );

Map<String, dynamic> _$RewardRedemptionToJson(RewardRedemption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'rewardId': instance.rewardId,
      'redeemedAt': instance.redeemedAt.toIso8601String(),
      'isProcessed': instance.isProcessed,
    };
