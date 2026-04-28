import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';

class LabelDetailScreen extends StatelessWidget {
  final String label;
  final bool isIncome;
  final List<Transaction> transactions;

  const LabelDetailScreen({
    super.key,
    required this.label,
    required this.isIncome,
    required this.transactions,
  });

  double get _total => transactions.fold(0.0, (s, t) => s + t.amount);

  String _fmt(double amount) => amount
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    final accentColor =
        isIncome ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final bgColor =
        isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE);
    final typeLabel = isIncome ? 'Ingreso' : 'Gasto';

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: context.textMain,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── Tarjeta de resumen ────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.card,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: context.shadow,
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    // Ícono + badge tipo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ),
                        Text(
                          '${transactions.length} movimiento${transactions.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSub,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Total
                    Text(
                      'Total acumulado',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.textSub,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${isIncome ? '+' : '-'}\$${_fmt(_total)}',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Encabezado de lista ───────────────────────────────────
              Text(
                'Movimientos',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.textMain,
                ),
              ),

              const SizedBox(height: 12),

              // ── Lista de transacciones ────────────────────────────────
              if (transactions.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Text(
                      'Sin movimientos para esta etiqueta',
                      style: TextStyle(fontSize: 13, color: context.textSub),
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: context.card,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: context.shadow,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      indent: 18,
                      endIndent: 18,
                      color: context.divider,
                    ),
                    itemBuilder: (context, idx) {
                      final t = transactions[idx];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: bgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isIncome
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            color: accentColor,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          t.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: context.textMain,
                          ),
                        ),
                        subtitle: Text(
                          'Movimiento #${idx + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.textSub,
                          ),
                        ),
                        trailing: Text(
                          '${isIncome ? '+' : '-'}\$${_fmt(t.amount)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
