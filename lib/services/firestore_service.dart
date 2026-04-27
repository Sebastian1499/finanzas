import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../models/transaction.dart';
import '../models/app_label.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Transacciones ────────────────────────────────────────────────────────

  /// Stream en tiempo real de las transacciones del usuario.
  Stream<List<Transaction>> transactionsStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Transaction.fromFirestore(doc))
            .toList());
  }

  /// Agregar una transacción nueva.
  Future<void> addTransaction(String userId, Transaction t) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(t.id)
        .set(t.toFirestore());
  }

  /// Actualizar una transacción existente.
  Future<void> updateTransaction(String userId, Transaction t) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(t.id)
        .update({
      'label': t.label,
      'amount': t.amount,
      'isIncome': t.isIncome,
    });
  }

  /// Eliminar una o varias transacciones.
  Future<void> deleteTransactions(String userId, List<String> ids) async {
    final batch = _db.batch();
    for (final id in ids) {
      final ref = _db
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(id);
      batch.delete(ref);
    }
    await batch.commit();
  }

  // ─── Etiquetas ────────────────────────────────────────────────────────────

  /// Stream en tiempo real de las etiquetas del usuario.
  Stream<List<AppLabel>> labelsStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('labels')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => AppLabel.fromFirestore(doc)).toList());
  }

  /// Inicializar etiquetas por defecto al crear cuenta.
  Future<void> initDefaultLabels(String userId) async {
    final batch = _db.batch();
    for (final label in defaultLabels) {
      final ref = _db
          .collection('users')
          .doc(userId)
          .collection('labels')
          .doc(label.id);
      batch.set(ref, label.toFirestore());
    }
    await batch.commit();
  }

  /// Agregar una etiqueta.
  Future<void> addLabel(String userId, AppLabel label) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('labels')
        .doc(label.id)
        .set(label.toFirestore());
  }

  /// Actualizar nombre o color de una etiqueta.
  Future<void> updateLabel(String userId, AppLabel label) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('labels')
        .doc(label.id)
        .update({
      'name': label.name,
      'color': label.color.toARGB32(),
    });
  }

  /// Eliminar una etiqueta.
  Future<void> deleteLabel(String userId, String labelId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('labels')
        .doc(labelId)
        .delete();
  }

  // ─── Perfil ───────────────────────────────────────────────────────────────

  /// Stream en tiempo real del perfil del usuario.
  Stream<Map<String, dynamic>> profileStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data() ?? {});
  }

  /// Actualizar un campo del perfil.
  Future<void> updateProfile(String userId, Map<String, dynamic> data) {
    return _db.collection('users').doc(userId).update(data);
  }
}
