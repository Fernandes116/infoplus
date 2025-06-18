import 'package:json_annotation/json_annotation.dart';

part 'price.g.dart';

@JsonSerializable()
class Price {
  final String id;
  final String item;
  final double value;
  final String province;
  final String market;
  final DateTime createdAt;

  Price({
    required this.id,
    required this.item,
    required this.value,
    required this.province,
    required this.market,
    required this.createdAt,
  });

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);
  Map<String, dynamic> toJson() => _$PriceToJson(this);
}
