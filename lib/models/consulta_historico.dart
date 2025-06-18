import 'package:json_annotation/json_annotation.dart';

part 'consulta_historico.g.dart';

@JsonSerializable()
class ConsultaHistorico {
  final String id;
  final DateTime timestamp;
  final String tipo;
  final String userId;
  final Map<String, dynamic> dados;
  final List<dynamic> detalhes; // Nova lista para armazenar vagas/preços

  ConsultaHistorico({
    required this.id,
    required this.timestamp,
    required this.tipo,
    required this.userId,
    required this.dados,
    required this.detalhes, // Novo campo obrigatório
  });

  factory ConsultaHistorico.fromJson(Map<String, dynamic> json) =>
      _$ConsultaHistoricoFromJson(json);

  Map<String, dynamic> toJson() => _$ConsultaHistoricoToJson(this);
}