import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import 'change_password_screen.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  // Valores del perfil cargados desde Firestore
  Map<String, String> _profile = {
    'name': '',
    'birthdate': '',
    'email': '',
    'phone': '',
    'currency': 'COP',
  };
  bool _loadingProfile = true;

  final _fs = FirestoreService();
  late final String _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _fs.profileStream(_uid).first;
    if (mounted) {
      setState(() {
        _profile = {
          'name': (data['name'] as String?) ?? '',
          'birthdate': (data['birthdate'] as String?) ?? '',
          'email': (data['email'] as String?) ?? '',
          'phone': (data['phone'] as String?) ?? '',
          'currency': (data['currency'] as String?) ?? 'COP',
        };
        _loadingProfile = false;
      });
    }
  }

  Future<void> _editBirthdate() async {
    // Parsear fecha actual si existe (formato dd/MM/yyyy)
    DateTime initial = DateTime(2000, 1, 1);
    final stored = _profile['birthdate'] ?? '';
    if (stored.isNotEmpty) {
      final parts = stored.split('/');
      if (parts.length == 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2]);
        if (d != null && m != null && y != null) initial = DateTime(y, m, d);
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'CO'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A1A2E),
            onPrimary: Colors.white,
            onSurface: Color(0xFF1A1A2E),
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null || !mounted) return;

    final formatted =
        '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    setState(() => _profile['birthdate'] = formatted);
    await _fs.updateProfile(_uid, {'birthdate': formatted});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Fecha de nacimiento actualizada'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  void _editPhone() {
    _CountryData selectedCountry = _kCountries.first;
    String initialNumber = _profile['phone'] ?? '';
    for (final c in _kCountries) {
      if (initialNumber.startsWith('${c.dialCode} ')) {
        selectedCountry = c;
        initialNumber = initialNumber.substring(c.dialCode.length + 1);
        break;
      } else if (initialNumber.startsWith(c.dialCode)) {
        selectedCountry = c;
        initialNumber = initialNumber.substring(c.dialCode.length);
        break;
      }
    }
    final numberController = TextEditingController(text: initialNumber);
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                color: ctx.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(color: ctx.handle, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Teléfono', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: ctx.textMain)),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDialog<_CountryData>(
                            context: ctx,
                            builder: (_) => _CountryPickerDialog(selected: selectedCountry),
                          );
                          if (picked != null) setModalState(() => selectedCountry = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(color: ctx.inputFill, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(selectedCountry.flag, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 6),
                              Text(selectedCountry.dialCode, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ctx.textMain)),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_drop_down_rounded, color: ctx.textSub, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: numberController,
                          style: TextStyle(color: ctx.textMain),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(selectedCountry.maxDigits),
                          ],
                          onChanged: (_) => setModalState(() => errorText = null),
                          decoration: InputDecoration(
                            hintText: 'Número',
                            errorText: errorText,
                            filled: true,
                            fillColor: ctx.inputFill,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${selectedCountry.minDigits == selectedCountry.maxDigits ? selectedCountry.minDigits.toString() : "${selectedCountry.minDigits}–${selectedCountry.maxDigits}"} dígitos para ${selectedCountry.name}',
                    style: TextStyle(fontSize: 12, color: ctx.textSub),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A2E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final number = numberController.text.trim().replaceAll(RegExp(r'\D'), '');
                        if (number.isEmpty) {
                          setModalState(() => errorText = 'Ingresa el número');
                          return;
                        }
                        if (number.length < selectedCountry.minDigits || number.length > selectedCountry.maxDigits) {
                          setModalState(() => errorText = selectedCountry.minDigits == selectedCountry.maxDigits
                            ? 'Debe tener ${selectedCountry.minDigits} dígitos'
                            : 'Debe tener entre ${selectedCountry.minDigits} y ${selectedCountry.maxDigits} dígitos');
                          return;
                        }
                        final fullPhone = '${selectedCountry.dialCode} $number';
                        Navigator.pop(ctx);
                        setState(() => _profile['phone'] = fullPhone);
                        await _fs.updateProfile(_uid, {'phone': fullPhone});
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text('Teléfono actualizado'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF1A1A2E),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ));
                        }
                      },
                      child: const Text('Guardar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _editCurrency() {
    final current = _profile['currency'] ?? 'COP';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: ctx.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: ctx.handle, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Moneda', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: ctx.textMain)),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.5),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _kCurrencies.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: ctx.divider),
                itemBuilder: (_, i) {
                  final c = _kCurrencies[i];
                  final isSelected = c.code == current;
                  return InkWell(
                    onTap: () async {
                      Navigator.pop(ctx);
                      setState(() => _profile['currency'] = c.code);
                      await _fs.updateProfile(_uid, {'currency': c.code});
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Moneda cambiada a ${c.code}'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF1A1A2E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF1A1A2E) : ctx.inputFill,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(c.symbol, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : ctx.textMain)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.code, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ctx.textMain)),
                                Text(c.name, style: TextStyle(fontSize: 12, color: ctx.textSub)),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_rounded, size: 20, color: ctx.textMain),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editField({
    required String title,
    required String fieldKey,
    bool isDate = false,
  }) {
    // El cambio de contraseña tiene su propia pantalla
    if (fieldKey == 'password') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
      );
      return;
    }

    final controller = TextEditingController(text: _profile[fieldKey]);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
            [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.handle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: context.textMain,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: TextStyle(color: context.textMain),
                keyboardType: isDate
                    ? TextInputType.datetime
                    : TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Nuevo valor',
                  filled: true,
                  fillColor: context.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A2E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final newValue = controller.text.trim();
                    if (newValue.isEmpty) return;
                    Navigator.pop(context);
                    setState(() => _profile[fieldKey] = newValue);
                    await _fs.updateProfile(_uid, {fieldKey: newValue});
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$title actualizado'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF1A1A2E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Guardar',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Configuración de usuario',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: context.textMain,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _loadingProfile
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF1A1A2E)))
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),

              // ── Avatar ────────────────────────────────────────────────
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A1A2E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person,
                          color: Colors.white, size: 42),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFEEEEEE), width: 1.5),
                        ),
                        child: const Icon(Icons.edit,
                            size: 14, color: Color(0xFF1A1A2E)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  _profile['name']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.textMain,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Sección: Información personal ─────────────────────────
              const _SectionHeader(title: 'Información personal'),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Nombre',
                    value: _profile['name']!,
                    onTap: () => _editField(
                        title: 'Nombre', fieldKey: 'name'),
                  ),
                  _SettingsTile(
                    icon: Icons.cake_outlined,
                    label: 'Fecha de nacimiento',
                    value: _profile['birthdate']!,
                    onTap: _editBirthdate,
                    isLast: true,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Sección: Cuenta y acceso ───────────────────────────────
              const _SectionHeader(title: 'Cuenta y acceso'),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: Icons.email_outlined,
                    label: 'Correo electrónico',
                    value: _profile['email']!,
                    onTap: () => _editField(
                        title: 'Correo electrónico', fieldKey: 'email'),
                  ),
                  _SettingsTile(
                    icon: Icons.phone_outlined,
                    label: 'Teléfono',
                    value: _profile['phone']!,
                    onTap: _editPhone,
                  ),
                  _SettingsTile(
                    icon: Icons.lock_outline_rounded,
                    label: 'Contraseña',
                    value: '••••••••',
                    onTap: () => _editField(
                        title: 'Contraseña',
                        fieldKey: 'password'),
                    isLast: true,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Sección: Preferencias ─────────────────────────────────
              const _SectionHeader(title: 'Preferencias'),
              const SizedBox(height: 12),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: Icons.attach_money_rounded,
                    label: 'Moneda',
                    value: _profile['currency']!,
                    onTap: _editCurrency,
                    isLast: true,
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

// ─── Country data ─────────────────────────────────────────────────────────────

class _CountryData {
  final String flag;
  final String name;
  final String dialCode;
  final int minDigits;
  final int maxDigits;
  const _CountryData({required this.flag, required this.name, required this.dialCode, required this.minDigits, required this.maxDigits});
}

const List<_CountryData> _kCountries = [
  _CountryData(flag: '🇨🇴', name: 'Colombia',          dialCode: '+57',  minDigits: 10, maxDigits: 10),
  _CountryData(flag: '🇲🇽', name: 'México',             dialCode: '+52',  minDigits: 10, maxDigits: 10),
  _CountryData(flag: '🇦🇷', name: 'Argentina',          dialCode: '+54',  minDigits: 10, maxDigits: 11),
  _CountryData(flag: '🇨🇱', name: 'Chile',              dialCode: '+56',  minDigits: 8,  maxDigits: 9),
  _CountryData(flag: '🇵🇪', name: 'Perú',               dialCode: '+51',  minDigits: 9,  maxDigits: 9),
  _CountryData(flag: '🇻🇪', name: 'Venezuela',          dialCode: '+58',  minDigits: 10, maxDigits: 10),
  _CountryData(flag: '🇪🇨', name: 'Ecuador',            dialCode: '+593', minDigits: 9,  maxDigits: 9),
  _CountryData(flag: '🇧🇴', name: 'Bolivia',            dialCode: '+591', minDigits: 8,  maxDigits: 8),
  _CountryData(flag: '🇵🇾', name: 'Paraguay',           dialCode: '+595', minDigits: 9,  maxDigits: 9),
  _CountryData(flag: '🇺🇾', name: 'Uruguay',            dialCode: '+598', minDigits: 8,  maxDigits: 9),
  _CountryData(flag: '🇧🇷', name: 'Brasil',             dialCode: '+55',  minDigits: 10, maxDigits: 11),
  _CountryData(flag: '🇵🇦', name: 'Panamá',             dialCode: '+507', minDigits: 7,  maxDigits: 8),
  _CountryData(flag: '🇨🇷', name: 'Costa Rica',         dialCode: '+506', minDigits: 8,  maxDigits: 8),
  _CountryData(flag: '🇬🇹', name: 'Guatemala',          dialCode: '+502', minDigits: 8,  maxDigits: 8),
  _CountryData(flag: '🇭🇳', name: 'Honduras',           dialCode: '+504', minDigits: 8,  maxDigits: 8),
  _CountryData(flag: '🇸🇻', name: 'El Salvador',        dialCode: '+503', minDigits: 8,  maxDigits: 8),
  _CountryData(flag: '🇳🇮', name: 'Nicaragua',          dialCode: '+505', minDigits: 8,  maxDigits: 8),
  _CountryData(flag: '🇩🇴', name: 'Rep. Dominicana',    dialCode: '+1',   minDigits: 10, maxDigits: 10),
  _CountryData(flag: '🇨🇺', name: 'Cuba',               dialCode: '+53',  minDigits: 8,  maxDigits: 8),
  _CountryData(flag: '🇪🇸', name: 'España',             dialCode: '+34',  minDigits: 9,  maxDigits: 9),
  _CountryData(flag: '🇺🇸', name: 'Estados Unidos',     dialCode: '+1',   minDigits: 10, maxDigits: 10),
  _CountryData(flag: '🇨🇦', name: 'Canadá',             dialCode: '+1',   minDigits: 10, maxDigits: 10),
];

// ─── Currency data ────────────────────────────────────────────────────────────

class _CurrencyData {
  final String code;
  final String name;
  final String symbol;
  const _CurrencyData({required this.code, required this.name, required this.symbol});
}

const List<_CurrencyData> _kCurrencies = [
  _CurrencyData(code: 'COP', name: 'Peso colombiano',      symbol: r'$'),
  _CurrencyData(code: 'MXN', name: 'Peso mexicano',         symbol: r'$'),
  _CurrencyData(code: 'ARS', name: 'Peso argentino',        symbol: r'$'),
  _CurrencyData(code: 'CLP', name: 'Peso chileno',          symbol: r'$'),
  _CurrencyData(code: 'PEN', name: 'Sol peruano',           symbol: 'S/'),
  _CurrencyData(code: 'VES', name: 'Bolívar venezolano',    symbol: 'Bs'),
  _CurrencyData(code: 'USD', name: 'Dólar estadounidense',  symbol: r'$'),
  _CurrencyData(code: 'EUR', name: 'Euro',                  symbol: '€'),
  _CurrencyData(code: 'BRL', name: 'Real brasileño',        symbol: r'R$'),
  _CurrencyData(code: 'BOB', name: 'Boliviano',             symbol: 'Bs'),
  _CurrencyData(code: 'PYG', name: 'Guaraní paraguayo',     symbol: '₲'),
  _CurrencyData(code: 'UYU', name: 'Peso uruguayo',         symbol: r'$U'),
  _CurrencyData(code: 'GTQ', name: 'Quetzal guatemalteco',  symbol: 'Q'),
  _CurrencyData(code: 'HNL', name: 'Lempira hondureño',     symbol: 'L'),
  _CurrencyData(code: 'CRC', name: 'Colón costarricense',   symbol: '₡'),
  _CurrencyData(code: 'DOP', name: 'Peso dominicano',       symbol: r'RD$'),
  _CurrencyData(code: 'CUP', name: 'Peso cubano',           symbol: r'$'),
  _CurrencyData(code: 'PAB', name: 'Balboa panameño',       symbol: 'B/.'),
];

// ─── Country picker dialog ────────────────────────────────────────────────────

class _CountryPickerDialog extends StatefulWidget {
  final _CountryData selected;
  const _CountryPickerDialog({required this.selected});

  @override
  State<_CountryPickerDialog> createState() => _CountryPickerDialogState();
}

class _CountryPickerDialogState extends State<_CountryPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _kCountries
        .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()) || c.dialCode.contains(_query))
        .toList();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecciona el país', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Buscar país...',
                prefixIcon: const Icon(Icons.search, size: 18),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final c = filtered[i];
                  final isSelected = c.dialCode == widget.selected.dialCode && c.name == widget.selected.name;
                  return InkWell(
                    onTap: () => Navigator.pop(context, c),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      child: Row(
                        children: [
                          Text(c.flag, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(c.name, style: const TextStyle(fontSize: 14))),
                          Text(c.dialCode, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal, color: isSelected ? const Color(0xFF1A1A2E) : const Color(0xFF888888))),
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.check_rounded, size: 16, color: Color(0xFF1A1A2E)),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.textSub,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

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
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isLast;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(14))
              : BorderRadius.zero,
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                Icon(icon, size: 20, color: context.textMain),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textMain,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textSub,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: context.textSub,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(height: 1, indent: 52, endIndent: 18,
              color: context.divider),
      ],
    );
  }
}
