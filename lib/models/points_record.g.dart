// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'points_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PointsRecord _$PointsRecordFromJson(Map<String, dynamic> json) => PointsRecord(
  userId: json['userId'] as String,
  points: (json['points'] as num).toInt(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  source: json['source'] as String,
);

Map<String, dynamic> _$PointsRecordToJson(PointsRecord instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'points': instance.points,
      'timestamp': instance.timestamp.toIso8601String(),
      'source': instance.source,
    };
