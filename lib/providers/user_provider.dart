import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _currentUser;
  String? _error;
  bool _loading = false;
  List<UserModel> _allUsers = [];

  UserModel? get currentUser => _currentUser;
  String? get error => _error;
  bool get loading => _loading;
  List<UserModel> get allUsers => _allUsers;

  Future<void> initializeUser() async {
    try {
      _loading = true;
      notifyListeners();

      final fbUser = _auth.currentUser;
      if (fbUser == null) {
        _error = 'Usuário não autenticado.';
        _loading = false;
        notifyListeners();
        return;
      }

      final userDoc = await _firestore.collection('users').doc(fbUser.uid).get();
      
      if (userDoc.exists) {
        _currentUser = UserModel.fromJson(userDoc.data()!).copyWith(id: userDoc.id);
      } else {
        _currentUser = UserModel.fromFirebaseUser({
          'id': fbUser.uid,
          'name': fbUser.displayName ?? '',
          'email': fbUser.email ?? '',
          'phoneNumber': fbUser.phoneNumber ?? '',
          'province': '',
          'points': 0,
          'isAdmin': false,
          'isSuperAdmin': false,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        await _firestore.collection('users').doc(fbUser.uid).set(
          _currentUser!.toJson(),
        );
      }
      
      _error = null;
    } on FirebaseException catch (e) {
      _error = 'Firebase error: ${e.message}';
      debugPrint(_error);
    } catch (e) {
      _error = 'Falha ao carregar usuário: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllUsers() async {
    try {
      _loading = true;
      notifyListeners();

      final query = await _firestore.collection('users').get();
      _allUsers = query.docs
          .map((doc) => UserModel.fromJson(doc.data()).copyWith(id: doc.id))
          .toList();
      
      _error = null;
    } catch (e) {
      _error = 'Falha ao carregar usuários: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> registerUser(UserModel user) async {
    try {
      _loading = true;
      notifyListeners();

      if (user.phoneNumber.isEmpty) {
        throw FormatException('Número de telefone é obrigatório');
      }

      await _firestore.collection('users').doc(user.id).set({
        ...user.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      _currentUser = user;
      _error = null;
    } catch (e) {
      _error = 'Falha ao registrar usuário: ${e.toString()}';
      debugPrint(_error);
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> getUserByPhone(String phoneNumber) async {
    try {
      if (phoneNumber.isEmpty) {
        throw FormatException('Número de telefone não pode ser vazio');
      }

      final query = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      return query.docs.isEmpty
          ? null
          : UserModel.fromJson(query.docs.first.data())
              .copyWith(id: query.docs.first.id);
    } catch (e) {
      _error = 'Falha ao buscar usuário: ${e.toString()}';
      debugPrint(_error);
      return null;
    }
  }

  Future<UserModel?> getUserById(String id) async {
    try {
      final doc = await _firestore.collection('users').doc(id).get();
      return doc.exists
          ? UserModel.fromJson(doc.data()!).copyWith(id: doc.id)
          : null;
    } catch (e) {
      _error = 'Falha ao buscar usuário: ${e.toString()}';
      debugPrint(_error);
      return null;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      _loading = true;
      notifyListeners();

      if (user.phoneNumber.isEmpty) {
        throw FormatException('Número de telefone é obrigatório');
      }

      await _firestore.collection('users').doc(user.id).update({
        ...user.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if (_currentUser?.id == user.id) {
        _currentUser = user;
      }
      
      _error = null;
    } catch (e) {
      _error = 'Falha ao atualizar usuário: ${e.toString()}';
      debugPrint(_error);
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateAdminStatus({
    required String userId,
    required bool isAdmin,
    required bool isSuperAdmin,
  }) async {
    try {
      _loading = true;
      notifyListeners();

      await _firestore.collection('users').doc(userId).update({
        'isAdmin': isAdmin,
        'isSuperAdmin': isSuperAdmin,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if (_currentUser?.id == userId) {
        _currentUser = _currentUser?.copyWith(
          isAdmin: isAdmin,
          isSuperAdmin: isSuperAdmin,
        );
      }
      
      // Atualiza a lista de usuários se necessário
      final index = _allUsers.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _allUsers[index] = _allUsers[index].copyWith(
          isAdmin: isAdmin,
          isSuperAdmin: isSuperAdmin,
        );
      }
      
      _error = null;
    } catch (e) {
      _error = 'Falha ao atualizar status de admin: ${e.toString()}';
      debugPrint(_error);
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addPoints(String userId, int points) async {
    try {
      final user = await getUserById(userId);
      if (user != null) {
        final updated = user.copyWith(points: user.points + points);
        await updateUser(updated);
      }
    } catch (e) {
      _error = 'Falha ao adicionar pontos: ${e.toString()}';
      debugPrint(_error);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      _allUsers = [];
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Falha ao fazer logout: ${e.toString()}';
      debugPrint(_error);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}