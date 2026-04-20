import 'dart:math';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'label_detail_screen.dart';

// ─── Paleta de colores para las porciones del pastel ─────────────────────────
const List<Color> _kPieColors = [
  Color(0xFF1A1A2E),
  Color(0xFFE57373),
  Color(0xFF4FC3F7),
  Color(0xFFFFA726),
  Color(0xFF66BB6A),
  Color(0xFF9575CD),
  Color(0xFFF06292),
  Color(0xFF26C6DA),
  Color(0xFFD4E157),
  Color(0xFFFF7043),
];

class StatisticsScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const StatisticsScreen({super.key, required this.transactions});

  List<Transaction> get _gastos =>
      transactions.where((t) => !t.isIncome).toList();
  List<Transaction> get _ganancias =>
      transactions.where((t) => t.isIncome).toList();

  /// Agrupa transacciones por etiqueta sumando sus montos.
  List<MapEntry<String, double>> _groupByLabel(List<Transaction> txs) {
    final map = <String, double>{};
    for (final t in txs) {
      map[t.label] = (map[t.label] ?? 0) + t.amount;
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted;
  }

  String _fmt(double amount) => amount
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    final gastosData = _groupByLabel(_gastos);
    final gananciasData = _groupByLabel(_ganancias);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // ── Header ────────────────────────────────────────────────
            const Center(
              child: Column(
                children: [
                  Text(
                    'Estadísticas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Toca una categoría para ver el detalle',
                    style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Gráfico de Gastos ─────────────────────────────────────
            _PieChartCard(
              title: 'Gastos por categoría',
              subtitle: 'Qué etiqueta consume más dinero',
              data: gastosData,
              allTransactions: _gastos,
              isIncome: false,
              emptyMessage: 'Sin gastos registrados',
              fmt: _fmt,
            ),

            const SizedBox(height: 20),

            // ── Gráfico de Ganancias ──────────────────────────────────
            _PieChartCard(
              title: 'Ganancias por categoría',
              subtitle: 'Qué etiqueta genera más dinero',
              data: gananciasData,
              allTransactions: _ganancias,
              isIncome: true,
              emptyMessage: 'Sin ganancias registradas',
              fmt: _fmt,
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta con gráfico interactivo ─────────────────────────────────────────

class _PieChartCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<MapEntry<String, double>> data;
  final List<Transaction> allTransactions;
  final bool isIncome;
  final String emptyMessage;
  final String Function(double) fmt;

  const _PieChartCard({
    required this.title,
    required this.subtitle,
    required this.data,
    required this.allTransactions,
    required this.isIncome,
    required this.emptyMessage,
    required this.fmt,
  });

  @override
  State<_PieChartCard> createState() => _PieChartCardState();
}

class _PieChartCardState extends State<_PieChartCard> {
  int? _pressedIndex;

  static const double _chartSize = 200.0;

  int? _sliceIndexAt(Offset localPosition) {
    final center = const Offset(_chartSize / 2, _chartSize / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final radius = _chartSize / 2 - 4;
    final holeRadius = radius * 0.48;
    if (distance < holeRadius || distance > radius) return null;

    var angle = atan2(dy, dx) + pi / 2;
    if (angle < 0) angle += 2 * pi;

    final total = widget.data.fold(0.0, (s, e) => s + e.value);
    double cumAngle = 0;
    for (int i = 0; i < widget.data.length; i++) {
      final sweep = (widget.data[i].value / total) * 2 * pi;
      if (angle <= cumAngle + sweep) return i;
      cumAngle += sweep;
    }
    return null;
  }

  void _navigateToDetail(int index) {
    setState(() => _pressedIndex = null);
    final label = widget.data[index].key;
    final filtered =
        widget.allTransactions.where((t) => t.label == label).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LabelDetailScreen(
          label: label,
          isIncome: widget.isIncome,
          transactions: filtered,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.subtitle,
            style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 24),

          if (widget.data.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  widget.emptyMessage,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
              ),
            )
          else ...[
            // ── Pastel interactivo ────────────────────────────────────
            Center(
              child: GestureDetector(
                onTapDown: (d) {
                  setState(() => _pressedIndex = _sliceIndexAt(d.localPosition));
                },
                onTapUp: (d) {
                  final idx = _sliceIndexAt(d.localPosition);
                  if (idx != null) _navigateToDetail(idx);
                  setState(() => _pressedIndex = null);
                },
                onTapCancel: () => setState(() => _pressedIndex = null),
                child: SizedBox(
                  width: _chartSize,
                  height: _chartSize,
                  child: CustomPaint(
                    painter: _PieChartPainter(
                      entries: widget.data,
                      selectedIndex: _pressedIndex,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Toca una porción para ver el historial',
                style: TextStyle(fontSize: 11, color: Color(0xFFBBBBBB)),
              ),
            ),
            const SizedBox(height: 20),

            // ── Leyenda tappable ──────────────────────────────────────
            ...widget.data.asMap().entries.map((e) {
              final idx = e.key;
              final label = e.value.key;
              final amount = e.value.value;
              final total = widget.data.fold(0.0, (s, x) => s + x.value);
              final pct = (amount / total * 100).toStringAsFixed(1);
              final color = _kPieColors[idx % _kPieColors.length];

              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _navigateToDetail(idx),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 7, horizontal: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF444444),
                          ),
                        ),
                      ),
                      Text(
                        '\$${widget.fmt(amount)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 42,
                        child: Text(
                          '$pct%',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: Color(0xFFCCCCCC),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

// ─── Pintor del pastel con resaltado ─────────────────────────────────────────

class _PieChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final int? selectedIndex;

  const _PieChartPainter({required this.entries, this.selectedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = min(size.width, size.height) / 2 - 4;
    final total = entries.fold(0.0, (s, e) => s + e.value);

    double startAngle = -pi / 2;

    for (int i = 0; i < entries.length; i++) {
      final sweepAngle = (entries[i].value / total) * 2 * pi;
      final color = _kPieColors[i % _kPieColors.length];
      final isSelected = selectedIndex == i;

      // Sector presionado: ligeramente expandido
      final radius = isSelected ? baseRadius + 7 : baseRadius;
      final rect = Rect.fromCircle(center: center, radius: radius);

      final fillPaint = Paint()
        ..color = isSelected ? color : color.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, fillPaint);

      // Separador blanco entre porciones
      final gapPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(rect, startAngle, sweepAngle, true, gapPaint);

      startAngle += sweepAngle;
    }

    // Hueco central (efecto dona)
    final holePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, baseRadius * 0.46, holePaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.entries != entries ||
      oldDelegate.selectedIndex != selectedIndex;
}
