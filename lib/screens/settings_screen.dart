import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'user_settings_screen.dart';
import 'change_password_screen.dart';
import 'labels_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // ── Header ────────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Text(
                    'Configuración',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Personaliza tu experiencia',
                    style: TextStyle(fontSize: 12, color: context.textSub),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ══════════════════════════════════════════════════════════
            // SECCIÓN 1 — Configuración de usuario
            // ══════════════════════════════════════════════════════════
            _SectionLabel(
              icon: Icons.person_rounded,
              label: 'Configuración de usuario',
              color: const Color(0xFF1A1A2E),
            ),
            const SizedBox(height: 12),

            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.manage_accounts_outlined,
                  title: 'Perfil y cuenta',
                  subtitle:
                      'Nombre, correo, contraseña, fecha de nacimiento…',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const UserSettingsScreen()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ══════════════════════════════════════════════════════════
            // SECCIÓN 2 — Seguridad
            // ══════════════════════════════════════════════════════════
            _SectionLabel(
              icon: Icons.lock_rounded,
              label: 'Seguridad',
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(height: 12),

            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.lock_reset_rounded,
                  title: 'Cambiar contraseña',
                  subtitle: 'Actualiza tu contraseña de acceso',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen()),
                  ),
                  isLast: true,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ══════════════════════════════════════════════════════════
            // SECCIÓN 3 — Etiquetas
            // ══════════════════════════════════════════════════════════
            _SectionLabel(
              icon: Icons.label_rounded,
              label: 'Etiquetas',
              color: const Color(0xFF6A1B9A),
            ),
            const SizedBox(height: 12),

            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.label_outline_rounded,
                  title: 'Gestionar etiquetas',
                  subtitle: 'Crear, editar, eliminar y asignar colores',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LabelsScreen()),
                  ),
                  isLast: true,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ══════════════════════════════════════════════════════════
            // SECCIÓN 4 — Configuración de la app
            // ══════════════════════════════════════════════════════════
            _SectionLabel(
              icon: Icons.tune_rounded,
              label: 'Configuración de la app',
              color: const Color(0xFF555555),
            ),
            const SizedBox(height: 12),

            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notificaciones',
                  subtitle: 'Alertas y recordatorios',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsScreen()),
                  ),
                ),
                _SettingsTile(
                  icon: Icons.color_lens_outlined,
                  title: 'Apariencia',
                  subtitle: 'Tema claro u oscuro',
                  onTap: () => _showThemePicker(context),
                ),
                _SettingsTile(
                  icon: Icons.language_rounded,
                  title: 'Idioma',
                  subtitle: 'Español',
                  onTap: () => _showComingSoon(context, 'Idioma'),
                ),
                _SettingsTile(
                  icon: Icons.security_rounded,
                  title: 'Privacidad y seguridad',
                  subtitle: 'PIN, biométrico, permisos',
                  onTap: () => _showComingSoon(context, 'Privacidad'),
                  isLast: true,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Cerrar sesión ─────────────────────────────────────────
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  title: 'Cerrar sesión',
                  subtitle: '',
                  titleColor: const Color(0xFFC62828),
                  iconColor: const Color(0xFFC62828),
                  showArrow: false,
                  onTap: () => _confirmLogout(context),
                  isLast: true,
                ),
              ],
            ),

            const SizedBox(height: 40),

            // ── Versión ───────────────────────────────────────────────
            Center(
              child: Text(
                'App Finanzas v1.0.0',
                style: TextStyle(fontSize: 11, color: context.textSub),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context) {
    final options = [
      (ThemeMode.system, Icons.brightness_auto_rounded,   'Según el sistema'),
      (ThemeMode.light,  Icons.light_mode_rounded,        'Claro'),
      (ThemeMode.dark,   Icons.dark_mode_rounded,         'Oscuro'),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, current, __) => Container(
          decoration: BoxDecoration(
            color: sheetCtx.card,
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
                  decoration: BoxDecoration(color: sheetCtx.handle, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Apariencia', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: sheetCtx.textMain)),
              const SizedBox(height: 16),
              ...options.map((o) {
                final (mode, icon, label) = o;
                final isSelected = current == mode;
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setTheme(mode);
                    Navigator.pop(sheetCtx);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1A1A2E) : sheetCtx.inputFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, size: 20, color: isSelected ? Colors.white : sheetCtx.textMain),
                        const SizedBox(width: 14),
                        Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : sheetCtx.textMain))),
                        if (isSelected) const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
        ),
        content: const Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // cerrar diálogo
              await AuthService().signOut();
              if (ctx.mounted) {
                Navigator.pushAndRemoveUntil(
                  ctx,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            child: const Text('Cerrar sesión',
                style: TextStyle(
                    color: Color(0xFFC62828), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — próximamente'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
      ],
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
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLast;
  final bool showArrow;
  final Color? titleColor;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isLast = false,
    this.showArrow = true,
    this.titleColor,
    this.iconColor,
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
                Icon(icon,
                    size: 22,
                    color: iconColor ?? context.textMain),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: titleColor ?? context.textMain,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSub,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showArrow)
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
          Divider(
              height: 1,
              indent: 54,
              endIndent: 18,
              color: context.divider),
      ],
    );
  }
}
