// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reward _$RewardFromJson(Map<String, dynamic> json) => Reward(
  id: json['id'] as String,
  name: json['name'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  points: (json['points'] as num).toInt(),
  pointsRequired: (json['pointsRequired'] as num).toInt(),
  type: json['type'] as String,
  value: (json['value'] as num).toDouble(),
  icon: json['icon'] as String,
  imageUrl: json['imageUrl'] as String,
);

Map<String, dynamic> _$RewardToJson(Reward instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'title': instance.title,
  'description': instance.description,
  'points': instance.points,
  'pointsRequired': instance.pointsRequired,
  'type': instance.type,
  'value': instance.value,
  'icon': instance.icon,
  'imageUrl': instance.imageUrl,
};
