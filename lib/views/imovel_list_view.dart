import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/imovel_provider.dart';
import '../widgets/province_selector.dart';
import '../models/imovel.dart'; // Importação adicionada

class ImovelListView extends StatefulWidget {
  const ImovelListView({super.key});

  @override
  State<ImovelListView> createState() => _ImovelListViewState();
}

class _ImovelListViewState extends State<ImovelListView> {
  String selectedProvince = 'Maputo';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _redirectToPayment();
  }

  Future<void> _redirectToPayment() async {
    final auth = context.read<AuthProvider>();
    if (auth.isAdmin) {
      await _loadImoveis();
      return;
    }

    await Navigator.pushReplacementNamed(context, '/payment', arguments: {
      'valor': 3,
      'tipo': 'imóveis',
      'pontos': 3,
      'destino': '/imoveis',
      'province': selectedProvince,
    });
  }

  Future<void> _loadImoveis() async {
    setState(() => _isLoading = true);
    await context.read<ImovelProvider>().fetchImoveis(selectedProvince);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final imoveis = context.watch<ImovelProvider>().imoveisByProvincia(selectedProvince);
   
    return Scaffold(
      appBar: AppBar(
        title: const Text('Imóveis Disponíveis'),
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/add-imovel'),
            ),
        ],
      ),
      body: Column(
        children: [
          ProvinceSelector(
            selected: selectedProvince,
            onChanged: (val) async {
              if (val != null) {
                setState(() => selectedProvince = val);
                await _redirectToPayment();
              }
            },
          ),
          _isLoading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: ListView.builder(
                    itemCount: imoveis.length,
                    itemBuilder: (_, index) {
                      final imovel = imoveis[index];
                      return _buildImovelCard(imovel, auth.isAdmin);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildImovelCard(Imovel imovel, bool isAdmin) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imovel.fotos.isNotEmpty ? imovel.fotos.first : 'https://via.placeholder.com/400x300',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  imovel.titulo,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${imovel.tipo == 'aluguel' ? 'Aluguel' : 'Venda'}: ${imovel.preco.toStringAsFixed(2)} MZN/mês',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text('Localização: ${imovel.localizacao}'),
                Text('${imovel.quartos} quartos • ${imovel.banheiros} banheiros • ${imovel.area}m²'),
                if (isAdmin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => context.read<ImovelProvider>().deleteImovel(imovel.id),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
