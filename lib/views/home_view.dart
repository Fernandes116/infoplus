import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/points_provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? provinciaSelecionada;

  @override
  void initState() {
    super.initState();
    _carregarProvinciaSalva();
  }

  Future<void> _carregarProvinciaSalva() async {
    final prefs = await SharedPreferences.getInstance();
    final prov = prefs.getString('provinciaSelecionada');
    setState(() {
      provinciaSelecionada = prov;
    });
  }

  Future<void> _selecionarProvincia(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    final provincias = [
      'Maputo Cidade',
      'Maputo Província',
      'Gaza',
      'Inhambane',
      'Sofala',
      'Manica',
      'Tete',
      'Zambézia',
      'Nampula',
      'Niassa',
      'Cabo Delgado',
    ];

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          children: provincias.map((provincia) {
            return ListTile(
              title: Text(provincia),
              onTap: () async {
                await prefs.setString('provinciaSelecionada', provincia);
                setState(() => provinciaSelecionada = provincia);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Província selecionada: $provincia')),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final points = context.watch<PointsProvider>().points;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Chip(
            label: Text('$points pts',
                style: const TextStyle(color: Colors.white)),
          ), // <<< VÍRGULA FALTAVA AQUI
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('InfoPlus',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Pontos: $points',
                      style: const TextStyle(color: Colors.white)),
                  if (provinciaSelecionada != null)
                    Text('Província: $provinciaSelecionada',
                        style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
            _buildDrawerItem(context, Icons.work, 'Vagas', '/jobs'),
            _buildDrawerItem(context, Icons.shopping_basket, 'Preços', '/prices'),
            _buildDrawerItem(context, Icons.home, 'Imóveis', '/imoveis'),
            _buildDrawerItem(context, Icons.card_giftcard, 'Brindes', '/rewards'),
            _buildDrawerItem(context, Icons.history, 'Histórico', '/historico'),
            if (auth.isAdmin) ...[
              const Divider(),
              _buildDrawerItem(
                context,
                Icons.admin_panel_settings,
                'Admin',
                '/admin',
                color: Colors.red,
              ),
            ],
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Bem-vindo ao InfoPlus!',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (provinciaSelecionada != null)
                      Text('Província atual: $provinciaSelecionada',
                          style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.location_on),
                      label: const Text('Alterar Província'),
                      onPressed: () => _selecionarProvincia(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildFeatureButton(context, Icons.work, 'Vagas', '/jobs'),
                  _buildFeatureButton(context, Icons.shopping_basket, 'Preços', '/prices'),
                  _buildFeatureButton(context, Icons.home, 'Imóveis', '/imoveis'),
                  _buildFeatureButton(context, Icons.card_giftcard, 'Brindes', '/rewards'),
                  _buildFeatureButton(context, Icons.history, 'Histórico', '/historico'),
                  if (auth.isAdmin)
                    _buildFeatureButton(
                      context,
                      Icons.admin_panel_settings,
                      'Admin',
                      '/admin',
                      color: Colors.red,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon,
      String title, String routeName, {Color color = Colors.blue}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title,
          style: TextStyle(color: color == Colors.red ? Colors.red : null)),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, routeName);
      },
    );
  }

  Widget _buildFeatureButton(BuildContext context, IconData icon,
      String label, String routeName, {Color color = Colors.blue}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
      ),
      onPressed: () => Navigator.pushNamed(context, routeName),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
