import 'dart:math';
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

  /// Genera un ID único local para la transacción.
  static String _generateId() {
    final rand = Random();
    return List.generate(20, (_) => rand.nextInt(16).toRadixString(16)).join();
  }

  /// Constructor rápido para crear una transacción nueva.
  factory Transaction.create({
    required String label,
    required double amount,
    required bool isIncome,
  }) {
    return Transaction(
      id: _generateId(),
      label: label,
      amount: amount,
      isIncome: isIncome,
      createdAt: DateTime.now(),
    );
  }

  /// Construir desde JSON devuelto por la API REST.
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      label: json['label'] as String,
      amount: (json['amount'] as num).toDouble(),
      isIncome: json['isIncome'] as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Serializar para enviar a la API REST.
  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'amount': amount,
        'isIncome': isIncome,
        'createdAt': createdAt.toIso8601String(),
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
