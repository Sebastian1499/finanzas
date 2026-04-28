import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_notification.dart';
import '../models/transaction.dart';

class NotificationService {
  static const _prefsKey = 'read_notification_ids';

  /// Adds the current date to the ID so notifications reset each day.
  static String _dailyId(String base) {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return '${base}_$date';
  }

  /// Generates the list of currently active alerts from [transactions].
  /// Pass [readIds] (from [getReadIds]) to know which are already read.
  static List<AppNotification> generate(
    List<Transaction> transactions,
    Set<String> readIds,
  ) {
    final egresos = transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (s, t) => s + t.amount);
    final ingresos = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (s, t) => s + t.amount);
    final saldo = ingresos - egresos;

    final now = DateTime.now();
    final hasTodayTx = transactions.any((t) =>
        t.createdAt.year == now.year &&
        t.createdAt.month == now.month &&
        t.createdAt.day == now.day);

    final List<AppNotification> result = [];

    // ── Saldo negativo ────────────────────────────────────────────────────
    if (saldo < 0) {
      final id = _dailyId('saldo_negativo');
      result.add(AppNotification(
        id: id,
        title: 'Saldo negativo',
        body: 'Tus egresos superan tus ingresos. Revisa tus gastos.',
        icon: Icons.trending_down_rounded,
        color: const Color(0xFFC62828),
        isRead: readIds.contains(id),
      ));
    }

    // ── Egresos elevados (> 80 % de ingresos, pero saldo aún positivo) ──
    if (saldo >= 0 && ingresos > 0 && egresos / ingresos > 0.8) {
      final id = _dailyId('egresos_alto');
      result.add(AppNotification(
        id: id,
        title: 'Egresos elevados',
        body: 'Tus egresos superan el 80 % de tus ingresos. Cuidado con el límite.',
        icon: Icons.warning_amber_rounded,
        color: const Color(0xFFE65100),
        isRead: readIds.contains(id),
      ));
    }

    // ── Sin movimientos hoy ───────────────────────────────────────────────
    if (transactions.isNotEmpty && !hasTodayTx) {
      final id = _dailyId('sin_movimientos_hoy');
      result.add(AppNotification(
        id: id,
        title: 'Sin movimientos hoy',
        body: 'No has registrado ningún movimiento hoy. ¿Olvidaste algo?',
        icon: Icons.calendar_today_rounded,
        color: const Color(0xFF1565C0),
        isRead: readIds.contains(id),
      ));
    }

    // ── Buen control de gastos ────────────────────────────────────────────
    if (saldo > 0 &&
        ingresos > 0 &&
        egresos / ingresos < 0.3 &&
        transactions.length >= 3) {
      final id = _dailyId('ahorro_bueno');
      result.add(AppNotification(
        id: id,
        title: '¡Buen control de gastos!',
        body: 'Tus egresos son menos del 30 % de tus ingresos. ¡Sigue así!',
        icon: Icons.thumb_up_alt_rounded,
        color: const Color(0xFF2E7D32),
        isRead: readIds.contains(id),
      ));
    }

    return result;
  }

  static Future<Set<String>> getReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefsKey)?.toSet() ?? {};
  }

  static Future<void> markAllRead(List<String> ids) async {
    if (ids.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_prefsKey)?.toSet() ?? {};
    existing.addAll(ids);
    await prefs.setStringList(_prefsKey, existing.toList());
  }
}
