import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/consulta_historico_provider.dart';
import '../models/user.dart';
import '../models/consulta_historico.dart';

class AdminView extends StatefulWidget {
  const AdminView({Key? key}) : super(key: key);

  @override
  _AdminViewState createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchAllUsers();
      context.read<ConsultaHistoricoProvider>().fetchHistorico();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAdmin && !auth.isSuperAdmin) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Acesso restrito a administradores',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Administração'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.people), text: 'Usuários'),
            Tab(icon: Icon(Icons.settings), text: 'Configurações'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<UserProvider>().fetchAllUsers();
              context.read<ConsultaHistoricoProvider>().fetchHistorico();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(context),
          _buildUsersTab(context),
          _buildSettingsTab(context),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(BuildContext context) {
    final historicoProvider = context.watch<ConsultaHistoricoProvider>();
    final List<ConsultaHistorico> historicos = historicoProvider.consultas;

    // Função para calcular valores por tipo
    double _calcularValorPorTipo(String tipo) {
      return historicos.where((h) => h.tipo == tipo).fold<double>(0, (sum, h) {
        return sum + (h.dados['valor'] as double? ?? 
                     (tipo == 'vagas' ? 3.0 : 
                      tipo == 'imóveis' ? 3.0 : 2.0));
      });
    }

    // Estatísticas gerais
    final totalConsultas = historicos.length;
    final totalLucro = _calcularValorPorTipo('vagas') + 
                      _calcularValorPorTipo('preços') + 
                      _calcularValorPorTipo('imóveis');

    // Filtra apenas o mês atual
    final now = DateTime.now();
    final inicioMes = DateTime(now.year, now.month, 1);
    final mensais = historicos.where((h) => h.timestamp.isAfter(inicioMes)).toList();

    final totalConsultasMensal = mensais.length;
    final lucroMensal = mensais.fold<double>(0, (sum, h) {
      return sum + (h.dados['valor'] as double? ?? 
                   (h.tipo == 'vagas' ? 3.0 : 
                    h.tipo == 'imóveis' ? 3.0 : 2.0));
    });

    return RefreshIndicator(
      onRefresh: () async {
        await historicoProvider.fetchHistorico();
        await context.read<UserProvider>().fetchAllUsers();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Estatísticas Gerais',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumo Geral',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total de consultas:'),
                      Text(totalConsultas.toString()),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Lucro total:'),
                      Text('${totalLucro.toStringAsFixed(2)} Mts'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumo Mensal',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Consultas este mês:'),
                      Text(totalConsultasMensal.toString()),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Lucro este mês:'),
                      Text('${lucroMensal.toStringAsFixed(2)} Mts'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ações Rápidas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            children: [
              _buildActionCard(
                context,
                icon: Icons.work,
                title: 'Vagas',
                route: '/jobs',
                color: Colors.blue,
              ),
              _buildActionCard(
                context,
                icon: Icons.price_change,
                title: 'Preços',
                route: '/prices',
                color: Colors.green,
              ),
              _buildActionCard(
                context,
                icon: Icons.home,
                title: 'Imóveis',
                route: '/imoveis',
                color: Colors.orange,
              ),
              _buildActionCard(
                context,
                icon: Icons.card_giftcard,
                title: 'Recompensas',
                route: '/rewards',
                color: Colors.purple,
              ),
              _buildActionCard(
                context,
                icon: Icons.history,
                title: 'Histórico',
                route: '/historico',
                color: Colors.teal,
              ),
              _buildActionCard(
                context,
                icon: Icons.settings,
                title: 'Configurações',
                route: '/settings',
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();

    if (userProvider.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => userProvider.fetchAllUsers(),
      child: ListView.builder(
        itemCount: userProvider.allUsers.length,
        itemBuilder: (context, index) {
          final user = userProvider.allUsers[index];
          return UserAdminTile(
            user: user,
            currentUserId: authProvider.firebaseUser?.uid,
          );
        },
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (auth.isSuperAdmin) ...[
          const Text(
            'Configurações Avançadas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.red),
            title: const Text('Configurações de Segurança'),
            subtitle: const Text('Gerir permissões e acessos'),
            onTap: () => Navigator.pushNamed(context, '/security-settings'),
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on, color: Colors.green),
            title: const Text('Configurar Preços'),
            subtitle: const Text('Definir valores para consultas'),
            onTap: () => Navigator.pushNamed(context, '/price-settings'),
          ),
          const Divider(),
        ],
        const Text(
          'Ferramentas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.backup),
          title: const Text('Backup de Dados'),
          subtitle: const Text('Exportar dados do sistema'),
          onTap: () => Navigator.pushNamed(context, '/backup'),
        ),
        ListTile(
          leading: const Icon(Icons.analytics),
          title: const Text('Relatórios Avançados'),
          subtitle: const Text('Gerar relatórios detalhados'),
          onTap: () => Navigator.pushNamed(context, '/reports'),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserAdminTile extends StatelessWidget {
  final UserModel user;
  final String? currentUserId;

  const UserAdminTile({
    Key? key,
    required this.user,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isSuperAdmin
              ? Colors.blue
              : user.isAdmin
                  ? Colors.green
                  : Colors.grey,
          child: Text(
            user.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Text(user.phoneNumber),
            Text('Pontos: ${user.points}'),
            Text('Função: ${user.role}'),
            if (user.isAdmin || user.isSuperAdmin)
              Text(
                user.isSuperAdmin
                    ? 'Super Administrador'
                    : 'Administrador',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: currentUserId != user.id
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: user.isAdmin,
                    onChanged: (value) async {
                      await userProvider.updateAdminStatus(
                        userId: user.id,
                        isAdmin: value,
                        isSuperAdmin: user.isSuperAdmin,
                      );
                    },
                    activeColor: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: user.isSuperAdmin,
                    onChanged: (value) async {
                      await userProvider.updateAdminStatus(
                        userId: user.id,
                        isAdmin: user.isAdmin,
                        isSuperAdmin: value,
                      );
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              )
            : null,
        onTap: () {
          Navigator.pushNamed(
            context,
            '/user-details',
            arguments: user.id,
          );
        },
      ),
    );
  }
}