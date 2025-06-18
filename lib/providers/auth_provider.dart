import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  bool _isAdmin = false;
  bool _isSuperAdmin = false;
  bool _loading = false;
  String? _verificationId;
  int? _resendToken;

  User? get firebaseUser => _firebaseUser;
  bool get isAdmin => _isAdmin;
  bool get isSuperAdmin => _isSuperAdmin;
  bool get loading => _loading;
  String? get verificationId => _verificationId;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      await _checkAdminStatus();
    } else {
      _isAdmin = false;
      _isSuperAdmin = false;
    }
    notifyListeners();
  }

  Future<void> _checkAdminStatus() async {
    if (_firebaseUser == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(_firebaseUser!.uid).get();
      if (userDoc.exists) {
        _isAdmin = userDoc.data()?['isAdmin'] ?? false;
        _isSuperAdmin = userDoc.data()?['isSuperAdmin'] ?? false;
      }
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      _isAdmin = false;
      _isSuperAdmin = false;
    }
    notifyListeners();
  }

  Future<void> checkAuth() async {
    try {
      _loading = true;
      notifyListeners();
      await _auth.authStateChanges().first;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      if (_firebaseUser == null) throw Exception('Usuário não autenticado');
      
      final doc = await _firestore.collection('users').doc(_firebaseUser!.uid).get();
      if (!doc.exists) throw Exception('Perfil não encontrado');
      
      return doc.data()!;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      rethrow;
    }
  }

  Future<void> sendCode(String phoneNumber) async {
    try {
      _loading = true;
      notifyListeners();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          throw e;
        },
        codeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> verifyCode(String smsCode) async {
    try {
      _loading = true;
      notifyListeners();

      if (_verificationId == null) {
        throw FirebaseAuthException(
          code: 'invalid-verification-id',
          message: 'Verification ID is null',
        );
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      await _auth.signInWithCredential(credential);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _loading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _firebaseUser = null;
    _isAdmin = false;
    _isSuperAdmin = false;
    _verificationId = null;
    notifyListeners();
  }

  Future<void> updateAdminStatus(String userId, bool isAdmin, bool isSuperAdmin) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isAdmin': isAdmin,
        'isSuperAdmin': isSuperAdmin,
      });

      if (_firebaseUser?.uid == userId) {
        _isAdmin = isAdmin;
        _isSuperAdmin = isSuperAdmin;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating admin status: $e');
      rethrow;
    }
  }
}
