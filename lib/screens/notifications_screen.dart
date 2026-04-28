import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

// ─── Claves de preferencias ───────────────────────────────────────────────────
const _kRemDaily    = 'notif_reminder_daily';
const _kRemWeekly   = 'notif_summary_weekly';
const _kRemBudget   = 'notif_budget_alert';
const _kReminderH   = 'notif_reminder_hour';
const _kReminderM   = 'notif_reminder_min';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _daily   = true;
  bool _weekly  = true;
  bool _budget  = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _daily  = prefs.getBool(_kRemDaily)   ?? true;
      _weekly = prefs.getBool(_kRemWeekly)  ?? true;
      _budget = prefs.getBool(_kRemBudget)  ?? false;
      _reminderTime = TimeOfDay(
        hour:   prefs.getInt(_kReminderH) ?? 21,
        minute: prefs.getInt(_kReminderM) ?? 0,
      );
      _loading = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRemDaily,   _daily);
    await prefs.setBool(_kRemWeekly,  _weekly);
    await prefs.setBool(_kRemBudget,  _budget);
    await prefs.setInt(_kReminderH,   _reminderTime.hour);
    await prefs.setInt(_kReminderM,   _reminderTime.minute);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: const Color(0xFF1A1A2E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
      await _save();
    }
  }

  String _fmtTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
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
          'Notificaciones',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: context.textMain,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Icono decorativo ──────────────────────────────
                    Center(
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E).withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_rounded,
                            size: 34, color: Color(0xFF1A1A2E)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Controla qué alertas recibir\ny cuándo recibirlas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: context.textSub, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Recordatorios ─────────────────────────────────
                    _SectionHeader(label: 'Recordatorios'),
                    const SizedBox(height: 10),

                    _NotifCard(
                      children: [
                        _ToggleTile(
                          icon: Icons.today_rounded,
                          iconColor: const Color(0xFF1565C0),
                          title: 'Recordatorio diario',
                          subtitle: 'Aviso para registrar tus gastos del día',
                          value: _daily,
                          onChanged: (v) async {
                            setState(() => _daily = v);
                            await _save();
                          },
                        ),
                        Divider(height: 1, color: context.divider),
                        // Hora del recordatorio (solo visible si _daily activo)
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 200),
                          crossFadeState: _daily
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: InkWell(
                            onTap: _pickTime,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_rounded,
                                      size: 22, color: context.textSub),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Hora del recordatorio',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: context.textMain)),
                                        const SizedBox(height: 2),
                                        Text('Todos los días a esta hora',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: context.textSub)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: context.inputFill,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _fmtTime(_reminderTime),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: context.textMain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.chevron_right_rounded,
                                      size: 18, color: context.textSub),
                                ],
                              ),
                            ),
                          ),
                          secondChild: const SizedBox.shrink(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Resúmenes ─────────────────────────────────────
                    _SectionHeader(label: 'Resúmenes'),
                    const SizedBox(height: 10),

                    _NotifCard(
                      children: [
                        _ToggleTile(
                          icon: Icons.bar_chart_rounded,
                          iconColor: const Color(0xFF2E7D32),
                          title: 'Resumen semanal',
                          subtitle: 'Informe de ingresos y gastos cada semana',
                          value: _weekly,
                          isLast: true,
                          onChanged: (v) async {
                            setState(() => _weekly = v);
                            await _save();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Alertas ───────────────────────────────────────
                    _SectionHeader(label: 'Alertas'),
                    const SizedBox(height: 10),

                    _NotifCard(
                      children: [
                        _ToggleTile(
                          icon: Icons.warning_amber_rounded,
                          iconColor: const Color(0xFFE65100),
                          title: 'Alerta de gastos elevados',
                          subtitle: 'Aviso cuando una categoría supera lo habitual',
                          value: _budget,
                          isLast: true,
                          onChanged: (v) async {
                            setState(() => _budget = v);
                            await _save();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ── Nota informativa ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.inputFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 18, color: context.textSub),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Las notificaciones se enviarán si los permisos del dispositivo están habilitados. Puedes cambiar esto en la configuración de tu sistema.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: context.textSub,
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: context.textSub,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final List<Widget> children;
  const _NotifCard({required this.children});

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

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: context.textMain)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(fontSize: 12, color: context.textSub)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1A1A2E),
          ),
        ],
      ),
    );
  }
}
