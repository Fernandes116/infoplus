import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:infoplus/views/splash_view.dart';
import 'package:infoplus/views/login_view.dart';
import 'package:infoplus/providers/auth_provider.dart' as app_auth;
import 'package:infoplus/providers/connectivity_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FakeAuthProvider extends ChangeNotifier implements app_auth.AuthProvider {
  final User? _user;
  final bool _isLoading;
  bool _isAdmin = false;
  bool _isSuperAdmin = false;
  String? _verificationId;

  FakeAuthProvider({User? user, bool isLoading = false})
      : _user = user,
        _isLoading = isLoading;

  @override
  User? get firebaseUser => _user;

  @override
  bool get loading => _isLoading;

  @override
  bool get isAdmin => _isAdmin;

  @override
  bool get isSuperAdmin => _isSuperAdmin;

  @override
  String? get verificationId => _verificationId;

  Future<void> checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 100));
    notifyListeners();
  }

  Future<Map<String, dynamic>> fetchUserProfile() async {
    return {'name': 'Test User', 'email': 'test@example.com'};
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> sendCode(String phoneNumber) async {
    _verificationId = 'fake_verification_id';
  }

  @override
  Future<void> verifyCode(String smsCode) async {}

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> registerWithEmail({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signInWithPhone(String phone) async {}

  @override
  Future<void> updateAdminStatus(String userId, bool isAdmin, bool isSuperAdmin) async {
    _isAdmin = isAdmin;
    _isSuperAdmin = isSuperAdmin;
  }
}

class FakeConnectivityProvider extends ChangeNotifier implements ConnectivityProvider {
  bool _isOnline = true;

  @override
  bool get isConnected => _isOnline;

  void setOnlineStatus(bool status) {
    _isOnline = status;
    notifyListeners();
  }

  Future<void> checkConnectivity() async {
    await Future.delayed(const Duration(milliseconds: 50));
    notifyListeners();
  }
}

void main() {
  late FakeAuthProvider fakeAuthProvider;
  late FakeConnectivityProvider fakeConnectivityProvider;

  setUp(() {
    fakeAuthProvider = FakeAuthProvider(user: null);
    fakeConnectivityProvider = FakeConnectivityProvider();
    fakeConnectivityProvider.setOnlineStatus(true);
  });

  Widget buildTestableApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<app_auth.AuthProvider>.value(value: fakeAuthProvider),
        ChangeNotifierProvider<ConnectivityProvider>.value(value: fakeConnectivityProvider),
      ],
      child: MaterialApp(
        home: const SplashView(),
        routes: {
          '/login': (context) => const LoginView(),
          '/home': (context) => const Scaffold(body: Center(child: Text('Home'))),
          '/error': (context) => const Scaffold(body: Center(child: Text('Error'))),
        },
        onUnknownRoute: (_) => MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Route not found'))),
        ),
      ),
    );
  }

  testWidgets('Renderiza SplashView quando inicializado', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableApp());
    await tester.pump();
    expect(find.byType(SplashView), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    print('✅ Teste "Renderiza SplashView quando inicializado" passou com sucesso!');
  });

  testWidgets('Navega para LoginView quando não autenticado', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(LoginView), findsOneWidget);
    print('✅ Teste "Navega para LoginView quando não autenticado" passou com sucesso!');
  });

  testWidgets('Mostra erro de conexão quando offline', (WidgetTester tester) async {
    fakeConnectivityProvider.setOnlineStatus(false);
    await tester.pumpWidget(buildTestableApp());
    await tester.pump();
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    print('✅ Teste "Mostra erro de conexão quando offline" passou com sucesso!');
  });
}
