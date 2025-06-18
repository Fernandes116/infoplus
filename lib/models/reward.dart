import 'package:json_annotation/json_annotation.dart';

part 'reward.g.dart';

@JsonSerializable()
class Reward {
  final String id;
  final String name;
  final String title;
  final String description;
  final int points;
  final int pointsRequired;
  final String type; // 'sms', 'minutes', 'data'
  final double value; // quantidade (minutos, MB, etc.)
  final String icon;
  final String imageUrl;

  Reward({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.points,
    required this.pointsRequired,
    required this.type,
    required this.value,
    required this.icon,
    required this.imageUrl,
  });

  factory Reward.fromJson(Map<String, dynamic> json) => _$RewardFromJson(json);
  Map<String, dynamic> toJson() => _$RewardToJson(this);
}
