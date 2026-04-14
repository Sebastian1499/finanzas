import 'dart:math';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

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

  final List<Transaction> _transactions = [
    const Transaction(label: 'Sueldo', amount: 20000, isIncome: true),
    const Transaction(label: 'Viaje', amount: 50000, isIncome: true),
    const Transaction(label: 'Comida', amount: 10000, isIncome: false),
    const Transaction(label: 'Transporte', amount: 10000, isIncome: false),
  ];

  List<Transaction> get _ingresos =>
      _transactions.where((t) => t.isIncome).toList();
  List<Transaction> get _egresos =>
      _transactions.where((t) => !t.isIncome).toList();
  double get _totalIngresos =>
      _ingresos.fold(0.0, (s, t) => s + t.amount);
  double get _totalEgresos =>
      _egresos.fold(0.0, (s, t) => s + t.amount);
  double get _saldo => _totalIngresos - _totalEgresos;

  String _fmt(double amount) => amount
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');

  @override
  void initState() {
    super.initState();
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
    _pulseController.dispose();
    super.dispose();
  }

  void _goToAddTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          transactions: List.from(_transactions),
          onSave: (t) => setState(() => _transactions.add(t)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
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
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Inicio',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Controla tus finanzas personales',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Menú
                  IconButton(
                    icon: const Icon(
                      Icons.more_horiz,
                      color: Color(0xFF1A1A2E),
                    ),
                    onPressed: () {},
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
                          egresos: _totalEgresos,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Saldo',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF888888),
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

              // ── Sección Ingresos ───────────────────────────────────────
              _SectionCard(
                title: 'Ingresos',
                items: _ingresos,
              ),

              const SizedBox(height: 14),

              // ── Sección Egresos ────────────────────────────────────────
              _SectionCard(
                title: 'Egresos',
                items: _egresos,
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),

      // ── Barra de navegación ──────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1A1A2E),
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
            label: 'Ajustes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Cuentas',
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

  const _DonutChartPainter({required this.ingresos, required this.egresos});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 18;
    const strokeWidth = 28.0;
    final total = ingresos + egresos;

    // Track de fondo
    final trackPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
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
      oldDelegate.ingresos != ingresos || oldDelegate.egresos != egresos;
}

// ─── Modelos y widgets ─────────────────────────────────────────────────────────



class _SectionCard extends StatelessWidget {
  final String title;
  final List<Transaction> items;

  const _SectionCard({required this.title, required this.items});

  String _fmt(double amount) {
    final s = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF444444),
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
          ),
        ],
      ),
    );
  }
}
