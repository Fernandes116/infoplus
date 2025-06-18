import 'package:json_annotation/json_annotation.dart';

part 'job.g.dart';

@JsonSerializable()
class Job {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String province;
  final DateTime createdAt;
  final String userId;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.province,
    required this.createdAt,
    required this.userId,
  });

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);
  Map<String, dynamic> toJson() => _$JobToJson(this);
}
