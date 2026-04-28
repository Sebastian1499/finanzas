import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/app_label.dart';
import '../models/app_notification.dart';
import '../models/transaction.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import 'add_transaction_screen.dart';
import 'historial_screen.dart';
import 'notifications_panel.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final _fs = FirestoreService();
  late final String _uid;
  List<Transaction> _transactions = [];
  late StreamSubscription<List<Transaction>> _txSub;
  late StreamSubscription<List<AppLabel>> _labelSub;

  List<Transaction> get _ingresos =>
      _transactions.where((t) => t.isIncome).toList();
  List<Transaction> get _egresos =>
      _transactions.where((t) => !t.isIncome).toList();
  double get _totalIngresos =>
      _ingresos.fold(0.0, (s, t) => s + t.amount);
  double get _totalEgresos =>
      _egresos.fold(0.0, (s, t) => s + t.amount);
  double get _saldo => _totalIngresos - _totalEgresos;

  Set<String> _readNotifIds = {};

  List<AppNotification> get _activeNotifications =>
      NotificationService.generate(_transactions, _readNotifIds);

  int get _unreadCount =>
      _activeNotifications.where((n) => !n.isRead).length;

  bool _selectionMode = false;
  final Set<String> _selectedIds = {};

  String _fmt(double amount) => amount
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _txSub = _fs.transactionsStream(_uid).listen(
      (txs) { if (mounted) setState(() => _transactions = txs); },
    );
    _labelSub = _fs.labelsStream(_uid).listen(
      (lbls) { if (mounted) setState(() => globalLabels = lbls); },
    );
    _loadReadIds();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _txSub.cancel();
    _labelSub.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadReadIds() async {
    final ids = await NotificationService.getReadIds();
    if (mounted) setState(() => _readNotifIds = ids);
  }

  Future<void> _openNotifications() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationsPanel(
        notifications: _activeNotifications,
      ),
    );
    // Reload so badge clears after panel closes
    _loadReadIds();
  }

  void _goToAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          transactions: List.from(_transactions),
    onSave: (t) => _fs.addTransaction(_uid, t),
        ),
      ),
    );
  }

  // ── Selección múltiple ────────────────────────────────────────────────────

  void _enterSelection(String id) {
    setState(() {
      _selectionMode = true;
      _selectedIds.add(id);
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _deleteSelected() {
    final ids = _selectedIds.toList();
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
    _fs.deleteTransactions(_uid, ids);
  }

  void _showEditSheet(String id) {
    final t = _transactions.firstWhere((tx) => tx.id == id);
    final amountCtrl =
        TextEditingController(text: t.amount.toStringAsFixed(0));
    final allLabels = globalLabels.map((l) => l.name).toList();
    String selectedLabel = allLabels.contains(t.label)
        ? t.label
        : (allLabels.isNotEmpty ? allLabels.first : t.label);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: ctx.card,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ctx.handle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Editar movimiento',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: ctx.textMain,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Monto',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ctx.textSub,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountCtrl,
                  style: TextStyle(color: ctx.textMain),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    prefixStyle: TextStyle(color: ctx.textMain),
                    filled: true,
                    fillColor: ctx.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Etiqueta',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ctx.textSub,
                  ),
                ),
                const SizedBox(height: 8),
                if (allLabels.isEmpty)
                  Text(
                    'No hay etiquetas disponibles',
                    style:
                        TextStyle(color: ctx.textSub, fontSize: 13),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: ctx.inputFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedLabel,
                        isExpanded: true,
                        dropdownColor: ctx.card,
                        style: TextStyle(color: ctx.textMain),
                        items: globalLabels
                            .map(
                              (l) => DropdownMenuItem(
                                value: l.name,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: l.color,
                                          shape: BoxShape.circle),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(l.name,
                                        style: const TextStyle(
                                            fontSize: 14)),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setSheet(() => selectedLabel = v);
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A2E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final newAmount = double.tryParse(
                              amountCtrl.text.replaceAll(',', '.')) ??
                          t.amount;
                      final updated = t.copyWith(
                        label: selectedLabel,
                        amount: newAmount,
                      );
                      Navigator.pop(ctx);
                      setState(() {
                        _selectionMode = false;
                        _selectedIds.clear();
                      });
                      _fs.updateTransaction(_uid, updated);
                    },
                    child: const Text(
                      'Guardar cambios',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // ── Tab 0: Inicio ──────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const SizedBox(height: 24),

              // ── Header ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Avatar
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A1A2E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Título + subtítulo (centrado)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Inicio',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: context.textMain,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Controla tus finanzas personales',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ── Campana de notificaciones ──────────────────────
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: context.textMain,
                            size: 26,
                          ),
                          onPressed: _openNotifications,
                          padding: EdgeInsets.zero,
                          tooltip: 'Notificaciones',
                        ),
                        if (_unreadCount > 0)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Color(0xFFC62828),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$_unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Gráfica de dona (tappable + pulso) ───────────────────
              Center(
                child: GestureDetector(
                  onTap: _goToAddTransaction,
                  child: AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (context, child) => Transform.scale(
                      scale: _pulseAnim.value,
                      child: child,
                    ),
                    child: SizedBox(
                      width: 220,
                      height: 220,
                      child: CustomPaint(
                        painter: _DonutChartPainter(
                          ingresos: _totalIngresos,
                          egresos: _totalEgresos,                          trackColor: context.donutTrack,                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Saldo',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.textSub,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_saldo < 0 ? '-' : ''}\$${_fmt(_saldo.abs())}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: _saldo >= 0
                                      ? const Color(0xFF1A1A2E)
                                      : const Color(0xFFC62828),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Barra de selección ────────────────────────────────────
              if (_selectionMode) ...[
                _SelectionBar(
                  count: _selectedIds.length,
                  onCancel: _exitSelection,
                  onDelete: _deleteSelected,
                  onEdit: _selectedIds.length == 1
                      ? () => _showEditSheet(_selectedIds.first)
                      : null,
                ),
                const SizedBox(height: 14),
              ],

              // ── Sección Ingresos ───────────────────────────────────────
              _SectionCard(
                title: 'Ingresos',
                items: _ingresos,
                selectionMode: _selectionMode,
                selectedIds: _selectedIds,
                onLongPress: _enterSelection,
                onToggle: _toggleSelection,
              ),

              const SizedBox(height: 14),

              // ── Sección Egresos ──────────────────────────────────────────────────────
              _SectionCard(
                title: 'Egresos',
                items: _egresos,
                selectionMode: _selectionMode,
                selectedIds: _selectedIds,
                onLongPress: _enterSelection,
                onToggle: _toggleSelection,
              ),

              const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          // ── Tab 1: Historial ────────────────────────────────────────
          HistorialScreen(
            transactions: _transactions,
            onAddTransaction: _goToAddTransaction,
          ),

          // ── Tab 2: Estadísticas ───────────────────────────────────────
          StatisticsScreen(transactions: _transactions),

          // ── Tab 3: Configuración ───────────────────────────────────────────
          const SettingsScreen(),
        ],
      ),

      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _goToAddTransaction,
              backgroundColor: const Color(0xFF1A1A2E),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,

      // ── Barra de navegación ──────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: context.card,
        selectedItemColor: context.textMain,
        unselectedItemColor: const Color(0xFFAAAAAA),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
      ),
    );
  }
}

// ─── Gráfica de dona ──────────────────────────────────────────────────────────

class _DonutChartPainter extends CustomPainter {
  final double ingresos;
  final double egresos;
  final Color trackColor;

  const _DonutChartPainter({
    required this.ingresos,
    required this.egresos,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 18;
    const strokeWidth = 28.0;
    final total = ingresos + egresos;

    // Track de fondo
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Arco egresos (rojo)
    final gastosAngle = (egresos / total) * 2 * pi;
    final gastosPaint = Paint()
      ..color = const Color(0xFFE57373)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, -pi / 2, gastosAngle, false, gastosPaint);

    // Arco ingresos (navy)
    final ingresosAngle = (ingresos / total) * 2 * pi;
    final ingresosPaint = Paint()
      ..color = const Color(0xFF1A1A2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(rect, -pi / 2 + gastosAngle, ingresosAngle, false, ingresosPaint);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.ingresos != ingresos || oldDelegate.egresos != egresos || oldDelegate.trackColor != trackColor;
}

// ─── Modelos y widgets ─────────────────────────────────────────────────────────

// ── Barra de acción al seleccionar ───────────────────────────────────────────

class _SelectionBar extends StatelessWidget {
  final int count;
  final VoidCallback onCancel;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const _SelectionBar({
    required this.count,
    required this.onCancel,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded,
                color: Colors.white, size: 20),
            onPressed: onCancel,
            tooltip: 'Cancelar',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$count seleccionado${count == 1 ? '' : 's'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: Colors.white, size: 20),
              onPressed: onEdit,
              tooltip: 'Editar',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFEF9A9A), size: 22),
            onPressed: onDelete,
            tooltip: 'Eliminar seleccionados',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de sección con soporte de selección ───────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Transaction> items;
  final bool selectionMode;
  final Set<String> selectedIds;
  final void Function(String) onLongPress;
  final void Function(String) onToggle;

  const _SectionCard({
    required this.title,
    required this.items,
    required this.selectionMode,
    required this.selectedIds,
    required this.onLongPress,
    required this.onToggle,
  });

  String _fmt(double amount) => amount
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.textMain,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            final isSelected = selectedIds.contains(item.id);
            return GestureDetector(
              onLongPress: () => onLongPress(item.id),
              onTap: selectionMode ? () => onToggle(item.id) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1A1A2E).withValues(alpha: 0.07)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    // Checkbox animado
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: selectionMode
                          ? Padding(
                              key: const ValueKey('cb'),
                              padding: const EdgeInsets.only(right: 10),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF1A1A2E)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF1A1A2E)
                                        : const Color(0xFFBBBBBB),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 14)
                                    : null,
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey('no')),
                    ),
                    Expanded(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.textMain,
                        ),
                      ),
                    ),
                    Text(
                      item.isIncome
                          ? '+\$${_fmt(item.amount)}'
                          : '-\$${_fmt(item.amount)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: item.isIncome
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
