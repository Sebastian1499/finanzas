import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class Transaction {
  final String id;
  final String label;
  final double amount;
  final bool isIncome;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.label,
    required this.amount,
    required this.isIncome,
    required this.createdAt,
  });

  /// Constructor rápido para crear una transacción nueva (genera ID único).
  factory Transaction.create({
    required String label,
    required double amount,
    required bool isIncome,
  }) {
    return Transaction(
      id: FirebaseFirestore.instance
          .collection('_')
          .doc()
          .id, // ID único de Firestore
      label: label,
      amount: amount,
      isIncome: isIncome,
      createdAt: DateTime.now(),
    );
  }

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      label: data['label'] as String,
      amount: (data['amount'] as num).toDouble(),
      isIncome: data['isIncome'] as bool,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'label': label,
        'amount': amount,
        'isIncome': isIncome,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  Transaction copyWith({
    String? label,
    double? amount,
    bool? isIncome,
  }) =>
      Transaction(
        id: id,
        label: label ?? this.label,
        amount: amount ?? this.amount,
        isIncome: isIncome ?? this.isIncome,
        createdAt: createdAt,
      );
}
