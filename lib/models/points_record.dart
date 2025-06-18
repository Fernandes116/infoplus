import 'package:json_annotation/json_annotation.dart';

part 'points_record.g.dart';

@JsonSerializable()
class PointsRecord {
  final String userId;
  final int points;
  final DateTime timestamp;
  final String source;

  PointsRecord({
    required this.userId,
    required this.points,
    required this.timestamp,
    required this.source,
  });

  factory PointsRecord.fromJson(Map<String, dynamic> json) =>
      _$PointsRecordFromJson(json);

  Map<String, dynamic> toJson() => _$PointsRecordToJson(this);
}
