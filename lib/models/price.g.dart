// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Price _$PriceFromJson(Map<String, dynamic> json) => Price(
  id: json['id'] as String,
  item: json['item'] as String,
  value: (json['value'] as num).toDouble(),
  province: json['province'] as String,
  market: json['market'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PriceToJson(Price instance) => <String, dynamic>{
  'id': instance.id,
  'item': instance.item,
  'value': instance.value,
  'province': instance.province,
  'market': instance.market,
  'createdAt': instance.createdAt.toIso8601String(),
};
