import 'package:flutter/material.dart';
import '../models/transaction.dart';

class HistorialScreen extends StatefulWidget {
  final List<Transaction> transactions;
  final VoidCallback onAddTransaction;

  const HistorialScreen({
    super.key,
    required this.transactions,
    required this.onAddTransaction,
  });

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  String _filter = 'todos'; // 'todos' | 'ingresos' | 'egresos'
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Transaction> get _filtered {
    return widget.transactions.where((t) {
      final matchFilter = _filter == 'todos' ||
          (_filter == 'ingresos' && t.isIncome) ||
          (_filter == 'egresos' && !t.isIncome);
      final matchSearch =
          _search.isEmpty || t.label.toLowerCase().contains(_search.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();
  }

  double get _totalIngresos => widget.transactions
      .where((t) => t.isIncome)
      .fold(0.0, (s, t) => s + t.amount);
  double get _totalEgresos => widget.transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (s, t) => s + t.amount);
  double get _saldo => _totalIngresos - _totalEgresos;

  String _fmt(double amount) => amount
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return SafeArea(
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historial',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Todos tus movimientos',
                      style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: widget.onAddTransaction,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Resumen ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _SummaryChip(
                  label: 'Ingresos',
                  amount: _totalIngresos,
                  color: const Color(0xFF2E7D32),
                  bgColor: const Color(0xFFE8F5E9),
                  fmt: _fmt,
                ),
                const SizedBox(width: 10),
                _SummaryChip(
                  label: 'Egresos',
                  amount: _totalEgresos,
                  color: const Color(0xFFC62828),
                  bgColor: const Color(0xFFFFEBEE),
                  fmt: _fmt,
                ),
                const SizedBox(width: 10),
                _SummaryChip(
                  label: 'Saldo',
                  amount: _saldo,
                  color: _saldo >= 0
                      ? const Color(0xFF1A1A2E)
                      : const Color(0xFFC62828),
                  bgColor: const Color(0xFFF0F0F0),
                  fmt: _fmt,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Buscador ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
              decoration: InputDecoration(
                hintText: 'Buscar por etiqueta…',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFAAAAAA)),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Color(0xFFAAAAAA), size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Color(0xFFAAAAAA), size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Filtros ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Todos',
                  selected: _filter == 'todos',
                  count: widget.transactions.length,
                  onTap: () => setState(() => _filter = 'todos'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Ingresos',
                  selected: _filter == 'ingresos',
                  count: widget.transactions.where((t) => t.isIncome).length,
                  onTap: () => setState(() => _filter = 'ingresos'),
                  activeColor: const Color(0xFF2E7D32),
                  activeBg: const Color(0xFFE8F5E9),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Egresos',
                  selected: _filter == 'egresos',
                  count: widget.transactions.where((t) => !t.isIncome).length,
                  onTap: () => setState(() => _filter = 'egresos'),
                  activeColor: const Color(0xFFC62828),
                  activeBg: const Color(0xFFFFEBEE),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Lista ───────────────────────────────────────────────────────
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _search.isNotEmpty
                              ? Icons.search_off_rounded
                              : Icons.inbox_outlined,
                          size: 52,
                          color: const Color(0xFFCCCCCC),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _search.isNotEmpty
                              ? 'Sin resultados para "$_search"'
                              : 'No hay movimientos aún',
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFFAAAAAA)),
                        ),
                        if (_search.isEmpty) ...[
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: widget.onAddTransaction,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Agregar movimiento'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final t = items[i];
                      final showDivider = i < items.length - 1;
                      return _TransactionTile(
                          transaction: t,
                          fmt: _fmt,
                          showDivider: showDivider);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Resumen chip ───────────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final Color bgColor;
  final String Function(double) fmt;

  const _SummaryChip({
    required this.label,
    required this.amount,
    required this.color,
    required this.bgColor,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 2),
            Text(
              '\$${fmt(amount.abs())}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter chip ────────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final int count;
  final VoidCallback onTap;
  final Color activeColor;
  final Color activeBg;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.count,
    required this.onTap,
    this.activeColor = const Color(0xFF1A1A2E),
    this.activeBg = const Color(0xFFE8EAF0),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : const Color(0xFFEEEEEE),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? activeColor : const Color(0xFF888888),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: selected ? activeColor : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : const Color(0xFF888888),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Transaction tile ───────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final String Function(double) fmt;
  final bool showDivider;

  const _TransactionTile({
    required this.transaction,
    required this.fmt,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isIncome
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isIncome
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: isIncome
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isIncome ? 'Ingreso' : 'Egreso',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFFAAAAAA)),
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}\$${fmt(transaction.amount)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isIncome
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
      ],
    );
  }
}
