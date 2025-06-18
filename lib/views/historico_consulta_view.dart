import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/consulta_historico_provider.dart';
import '../models/consulta_historico.dart';

class HistoricoConsultasView extends StatefulWidget {
  const HistoricoConsultasView({super.key});

  @override
  State<HistoricoConsultasView> createState() => _HistoricoConsultasViewState();
}

class _HistoricoConsultasViewState extends State<HistoricoConsultasView> {
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final auth = context.read<AuthProvider>();
    if (auth.firebaseUser == null) return;
    
    final provider = context.read<ConsultaHistoricoProvider>();
    await provider.carregarHistorico(auth.firebaseUser!.uid);
  }

  List<ConsultaHistorico> _filterTodayConsultas(List<ConsultaHistorico> allConsultas) {
    final now = DateTime.now();
    return allConsultas.where((c) => 
        c.timestamp.year == now.year &&
        c.timestamp.month == now.month &&
        c.timestamp.day == now.day).toList();
  }

  @override
  Widget build(BuildContext context) {
    final consultas = _filterTodayConsultas(
      context.watch<ConsultaHistoricoProvider>().consultas
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Consultas (24h)')),
      body: consultas.isEmpty
          ? const Center(child: Text('Nenhuma consulta hoje.'))
          : ListView.builder(
              itemCount: consultas.length,
              itemBuilder: (_, i) {
                final c = consultas[i];
                return ExpansionTile(
                  leading: Icon(
                    c.tipo == 'vagas' ? Icons.work : Icons.price_change,
                  ),
                  title: Text('Consulta de ${c.tipo} - ${c.dados['provincia']}'),
                  subtitle: Text('${c.timestamp.toString()} - ${c.dados['valor']} MZN'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: c.detalhes.map<Widget>((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              c.tipo == 'vagas' 
                                ? '• ${item['title']} (${item['location']})' 
                                : '• ${item['item']}: ${item['value'].toStringAsFixed(2)} MZN',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}