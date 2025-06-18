import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/price_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/province_selector.dart';

class PriceListView extends StatefulWidget {
  const PriceListView({super.key});

  @override
  State<PriceListView> createState() => _PriceListViewState();
}

class _PriceListViewState extends State<PriceListView> {
  String selectedProvince = 'Maputo';
  bool _isLoading = false;

  Future<void> _handleRefresh() async {
    final auth = context.read<AuthProvider>();
    if (auth.isAdmin) {
      await context.read<PriceProvider>().fetchPrices(selectedProvince);
      return;
    }

    setState(() => _isLoading = true);
    await Navigator.pushReplacementNamed(context, '/payment', arguments: {
      'valor': 2,
      'tipo': 'preços',
      'pontos': 2,
      'destino': '/prices',
      'province': selectedProvince,
    });
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleRefresh());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final prices = context.watch<PriceProvider>().pricesByProvince(selectedProvince);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preços'),
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/add-price'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              child: Column(
                children: [
                  ProvinceSelector(
                    selected: selectedProvince,
                    onChanged: (val) async {
                      if (val != null) {
                        setState(() => selectedProvince = val);
                        await _handleRefresh();
                      }
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: prices.length,
                      itemBuilder: (_, i) {
                        final price = prices[i];
                        return ListTile(
                          title: Text(price.item),
                          subtitle: Text('${price.market} - ${price.province}'),
                          trailing: Text('${price.value.toStringAsFixed(2)} Mts'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
