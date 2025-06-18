// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imovel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Imovel _$ImovelFromJson(Map<String, dynamic> json) => Imovel(
  id: json['id'] as String,
  titulo: json['titulo'] as String,
  descricao: json['descricao'] as String,
  tipo: json['tipo'] as String,
  preco: (json['preco'] as num).toDouble(),
  localizacao: json['localizacao'] as String,
  provincia: json['provincia'] as String,
  quartos: (json['quartos'] as num).toInt(),
  banheiros: (json['banheiros'] as num).toInt(),
  area: (json['area'] as num).toDouble(),
  fotos: (json['fotos'] as List<dynamic>).map((e) => e as String).toList(),
  criadoEm: DateTime.parse(json['criadoEm'] as String),
  userId: json['userId'] as String,
);

Map<String, dynamic> _$ImovelToJson(Imovel instance) => <String, dynamic>{
  'id': instance.id,
  'titulo': instance.titulo,
  'descricao': instance.descricao,
  'tipo': instance.tipo,
  'preco': instance.preco,
  'localizacao': instance.localizacao,
  'provincia': instance.provincia,
  'quartos': instance.quartos,
  'banheiros': instance.banheiros,
  'area': instance.area,
  'fotos': instance.fotos,
  'criadoEm': instance.criadoEm.toIso8601String(),
  'userId': instance.userId,
};
