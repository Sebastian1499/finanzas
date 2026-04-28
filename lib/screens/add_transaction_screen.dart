import 'package:flutter/material.dart';
import '../models/app_label.dart';
import '../models/transaction.dart';
import '../theme/app_colors.dart';
import 'registro_exitoso_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  final List<Transaction> transactions;
  final void Function(Transaction) onSave;

  const AddTransactionScreen({
    super.key,
    required this.transactions,
    required this.onSave,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  bool _isIncome = true;
  final _amountController = TextEditingController();
  String? _selectedLabel;
  bool _submitted = false;

  /// Etiquetas tomadas de la lista global (sincronizada con Firestore).
  List<String> get _labels => globalLabels.map((l) => l.name).toList();

  bool get _amountHasError =>
      _submitted && _amountController.text.trim().isEmpty;
  bool get _labelHasError => _submitted && _selectedLabel == null;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _switchMode(bool isIncome) {
    if (_isIncome == isIncome) return;
    setState(() {
      _isIncome = isIncome;
      _selectedLabel = null;
    });
  }

  void _guardar() {
    setState(() => _submitted = true);

    final rawText = _amountController.text.trim();
    if (rawText.isEmpty || _selectedLabel == null) return;

    // Parse amount: remove $ and spaces, strip thousands dots, treat comma as decimal
    final cleaned = rawText
        .replaceAll(r'$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    final amount = double.tryParse(cleaned);
    if (amount == null || amount <= 0) {
      _showInvalidAmountDialog();
      return;
    }

    final transaction = Transaction.create(
      label: _selectedLabel!,
      amount: amount,
      isIncome: _isIncome,
    );

    widget.onSave(transaction);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegistroExitosoScreen(
          newTransaction: transaction,
          allTransactions: [...widget.transactions, transaction],
        ),
      ),
    );
  }


  void _showInvalidAmountDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: ctx.card,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A2E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Valor inválido',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'No puedes ingresar un valor negativo. Por favor ingresa un monto mayor a cero.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF666666),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A2E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1A1A2E) : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : context.textMain,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amountBorderColor =
        _amountHasError ? Colors.red : const Color(0xFFCCCCCC);
    final labelBorderColor =
        _labelHasError ? Colors.red : const Color(0xFFCCCCCC);

    return Scaffold(
      backgroundColor: context.card,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: context.textMain),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  _toggleBtn(
                      'Agregar ingresos', _isIncome, () => _switchMode(true)),
                  const SizedBox(width: 8),
                  _toggleBtn('Agregar egresos', !_isIncome,
                      () => _switchMode(false)),
                ],
              ),
            ),

            // ── Form ────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount field
                    Text(
                      _isIncome ? 'Ingresos' : 'Egresos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.textMain,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      style: TextStyle(
                          fontSize: 15, color: context.textMain),
                      onChanged: (_) {
                        if (_submitted) setState(() {});
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: amountBorderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _amountHasError
                                ? Colors.red
                                : const Color(0xFF1A1A2E),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    if (_amountHasError)
                      const Padding(
                        padding: EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          'Campo obligatorio',
                          style:
                              TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Label dropdown
                    Text(
                      'Etiquetas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.textMain,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: labelBorderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedLabel,
                          isExpanded: true,
                          hint: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Seleccionar etiqueta',
                              style: TextStyle(
                                  color: context.textSub, fontSize: 15),
                            ),
                          ),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          items: _labels
                              .map((l) => DropdownMenuItem(
                                    value: l,
                                    child: Text(l),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            setState(() => _selectedLabel = v);
                          },
                        ),
                      ),
                    ),
                    if (_labelHasError)
                      const Padding(
                        padding: EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          'Campo obligatorio',
                          style:
                              TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),

                    const SizedBox(height: 40),

                    // Guardar button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A2E),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Guardar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom nav ──────────────────────────────────────────────────────
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: context.card,
        selectedItemColor: const Color(0xFF1A1A2E),
        unselectedItemColor: const Color(0xFFAAAAAA),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Historial'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Estadísticas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Cuentas'),
        ],
      ),
    );
  }
}
