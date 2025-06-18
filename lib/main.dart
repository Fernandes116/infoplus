import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'config/env.dart';
import 'providers/connectivity_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/sync_provider.dart';
import 'providers/job_provider.dart';
import 'providers/price_provider.dart';
import 'providers/imovel_provider.dart';
import 'providers/reward_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/user_provider.dart';
import 'providers/consulta_historico_provider.dart';
import 'providers/points_provider.dart';
import 'views/splash_view.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'views/payment_view.dart';
import 'views/job_list_view.dart';
import 'views/price_list_view.dart';
import 'views/imovel_list_view.dart';
import 'views/reward_view.dart';
import 'views/admin_view.dart';
import 'views/register_view.dart';
import 'views/historico_consulta_view.dart';
import 'views/error_view.dart';
import 'services/firestore_service.dart';
import 'services/payment_service.dart';

Future<void> solicitarPermissoesSms() async {
  await [
    Permission.sms,
    Permission.phone,
    Permission.notification,
  ].request();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails details) => ErrorView(
    error: details.exception,
    stackTrace: details.stack,
  );

  try {
    await Firebase.initializeApp();
    await Env.load();
    await solicitarPermissoesSms();

    final connectivity = ConnectivityProvider();
    await connectivity.checkConnectivity();

    final firestoreService = FirestoreService();
    final paymentService = PaymentService();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: connectivity),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => PaymentProvider(paymentService)),
          ChangeNotifierProvider(create: (_) => SyncProvider()),
          ChangeNotifierProvider(create: (_) => JobProvider(firestoreService)),
          ChangeNotifierProvider(create: (_) => PriceProvider(firestoreService)),
          ChangeNotifierProvider(create: (_) => ImovelProvider(firestoreService)),
          ChangeNotifierProvider(create: (_) => RewardProvider(firestoreService)),
          ChangeNotifierProvider(create: (_) => AdminProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(
            create: (_) => ConsultaHistoricoProvider(firestoreService),
          ),
          ChangeNotifierProvider(create: (_) => PointsProvider(firestoreService)),
        ],
        child: const InfoPlusApp(),
      ),
    );
  } catch (e) {
    runApp(MaterialApp(home: ErrorView(error: e)));
  }
}

class InfoPlusApp extends StatelessWidget {
  const InfoPlusApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InfoPlus',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final auth = Provider.of<AuthProvider>(context, listen: false);

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => const SplashView(),
              settings: settings,
              fullscreenDialog: true,
            );
          case '/error':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => ErrorView(
                error: args?['error'],
                stackTrace: args?['stackTrace'],
              ),
            );
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginView());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterView());
          case '/home':
            return MaterialPageRoute(
              builder: (_) => auth.firebaseUser == null
                  ? const LoginView()
                  : const HomeView(),
            );
          case '/payment':
            if (auth.firebaseUser == null) return _redirectToLogin();
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => PaymentView(
                dados: args['dados'],
                selectedProvince: args['selectedProvince'],
              ),
            );
          case '/jobs':
            return _protectedRoute(const JobListView(), auth);
          case '/prices':
            return _protectedRoute(const PriceListView(), auth);
          case '/imoveis':
            return _protectedRoute(const ImovelListView(), auth);
          case '/rewards':
            return _protectedRoute(const RewardView(), auth);
          case '/historico':
            return _protectedRoute(const HistoricoConsultasView(), auth);
          case '/admin':
            return MaterialPageRoute(
              builder: (_) => (auth.firebaseUser != null && auth.isAdmin)
                  ? const AdminView()
                  : const HomeView(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const SplashView(),
              settings: settings,
            );
        }
      },
    );
  }

  MaterialPageRoute _protectedRoute(Widget view, AuthProvider auth) {
    return MaterialPageRoute(
      builder: (_) => auth.firebaseUser == null ? const LoginView() : view,
    );
  }

  MaterialPageRoute _redirectToLogin() {
    return MaterialPageRoute(builder: (_) => const LoginView());
  }
}
