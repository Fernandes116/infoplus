import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/connectivity_provider.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final connectivity = Provider.of<ConnectivityProvider>(context, listen: false);

      await Future.wait([
        Future.delayed(const Duration(seconds: 2)),
        connectivity.checkConnectivity(),
        auth.checkAuth(),
      ]);

      if (!mounted) return;

      if (!connectivity.isConnected) {
        _showConnectionError();
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        auth.firebaseUser != null ? '/home' : '/login',
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/error',
        arguments: {'error': e},
      );
    }
  }

  void _showConnectionError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Sem conexão'),
        content: const Text('Conecte-se à internet para continuar.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeApp();
            },
            child: const Text('Tentar novamente'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ConnectivityProvider>(
        builder: (_, connectivity, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/app/app_icon.png',
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return const FlutterLogo(size: 100);
                },
              ),
              const SizedBox(height: 20),
              if (connectivity.isConnected)
                const CircularProgressIndicator()
              else
                Column(
                  children: const [
                    Icon(Icons.wifi_off, size: 40, color: Colors.red),
                    SizedBox(height: 10),
                    Text('Conectando...'),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
