import 'package:json_annotation/json_annotation.dart';

part 'imovel.g.dart';

@JsonSerializable()
class Imovel {
  final String id;
  final String titulo;
  final String descricao;
  final String tipo; // 'aluguel' ou 'venda'
  final double preco;
  final String localizacao;
  final String provincia;
  final int quartos;
  final int banheiros;
  final double area;
  final List<String> fotos;
  final DateTime criadoEm;
  final String userId;

  Imovel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.preco,
    required this.localizacao,
    required this.provincia,
    required this.quartos,
    required this.banheiros,
    required this.area,
    required this.fotos,
    required this.criadoEm,
    required this.userId,
  });

  factory Imovel.fromJson(Map<String, dynamic> json) => _$ImovelFromJson(json);
  Map<String, dynamic> toJson() => _$ImovelToJson(this);
}