// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consulta_historico.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsultaHistorico _$ConsultaHistoricoFromJson(Map<String, dynamic> json) =>
    ConsultaHistorico(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      tipo: json['tipo'] as String,
      userId: json['userId'] as String,
      dados: json['dados'] as Map<String, dynamic>,
      detalhes: json['detalhes'] as List<dynamic>,
    );

Map<String, dynamic> _$ConsultaHistoricoToJson(ConsultaHistorico instance) =>
    <String, dynamic>{
      'id': instance.id,
      'timestamp': instance.timestamp.toIso8601String(),
      'tipo': instance.tipo,
      'userId': instance.userId,
      'dados': instance.dados,
      'detalhes': instance.detalhes,
    };
