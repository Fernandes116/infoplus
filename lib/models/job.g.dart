// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Job _$JobFromJson(Map<String, dynamic> json) => Job(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  location: json['location'] as String,
  province: json['province'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  userId: json['userId'] as String,
);

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'location': instance.location,
  'province': instance.province,
  'createdAt': instance.createdAt.toIso8601String(),
  'userId': instance.userId,
};
