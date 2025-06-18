import 'package:flutter_test/flutter_test.dart';
import 'package:infoplus/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('User model', () {
    test('toJson e fromJson funcionam corretamente', () {
      // 1. Cria um usuário de teste com dados conhecidos
      final user = UserModel(
        id: '123',
        name: 'Joana',
        phoneNumber: '+258841234567',
        email: 'joana@example.com',
        province: 'Maputo',
        points: 0,
        isAdmin: false,
        role: 'user',
      );

      // 2. Converte para JSON e depois de volta para objeto
      final json = user.toJson();
      final fromJson = UserModel.fromJson(json);

      // 3. Verifica se todos os campos foram preservados corretamente
      expect(fromJson.id, user.id, reason: 'O ID deve ser o mesmo após serialização');
      expect(fromJson.name, user.name, reason: 'O nome deve ser preservado');
      expect(fromJson.phoneNumber, user.phoneNumber, reason: 'O número de telefone deve ser igual');
      expect(fromJson.province, user.province, reason: 'A província deve ser a mesma');
      expect(fromJson.points, user.points, reason: 'Os pontos devem ser iguais');
      expect(fromJson.isAdmin, user.isAdmin, reason: 'O status de admin deve ser preservado');
      expect(fromJson.role, user.role, reason: 'O papel do usuário deve ser o mesmo');

      print('✅ Teste "toJson e fromJson" passou com sucesso! Todos os campos foram serializados corretamente.');
    });

    test('fromFirebaseUser funciona corretamente', () {
      // 1. Prepara dados de teste com timestamp atual
      final now = DateTime.now();
      final timestamp = Timestamp.fromDate(now);

      // 2. Cria um mapa simulando dados do Firestore
      final userData = {
        'id': '456',
        'name': 'Carlos',
        'phoneNumber': '+258842345678',
        'email': 'carlos@example.com',
        'province': 'Gaza',
        'points': 10,
        'isAdmin': true,
        'isSuperAdmin': false,
        'role': 'admin',
        'createdAt': timestamp,
        'updatedAt': timestamp,
      };

      // 3. Converte os dados do Firestore para UserModel
      final user = UserModel.fromFirebaseUser(userData);

      // 4. Verifica se todos os campos foram mapeados corretamente
      expect(user.id, userData['id'], reason: 'ID deve corresponder ao dado original');
      expect(user.name, userData['name'], reason: 'Nome deve ser igual ao fornecido');
      expect(user.phoneNumber, userData['phoneNumber'], reason: 'Número de telefone deve ser preservado');
      expect(user.province, userData['province'], reason: 'Província deve ser mapeada corretamente');
      expect(user.points, userData['points'], reason: 'Pontos devem ser os mesmos');
      expect(user.isAdmin, userData['isAdmin'], reason: 'Status de admin deve ser preservado');
      expect(user.role, userData['role'], reason: 'Papel do usuário deve ser o mesmo');
      expect(user.createdAt, timestamp.toDate(), reason: 'Data de criação deve ser convertida corretamente');
      expect(user.updatedAt, timestamp.toDate(), reason: 'Data de atualização deve ser convertida corretamente');

      print('✅ Teste "fromFirebaseUser" passou com sucesso! Todos os campos do Firestore foram mapeados corretamente.');
    });
  });
}
