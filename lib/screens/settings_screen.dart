import 'package:flutter/material.dart';
import 'user_settings_screen.dart';
import 'change_password_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
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
            const Center(
              child: Column(
                children: [
                  Text(
                    'Configuración',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Personaliza tu experiencia',
                    style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
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
            // SECCIÓN 2 — Acceso
            // ══════════════════════════════════════════════════════════
            _SectionLabel(
              icon: Icons.login_rounded,
              label: 'Acceso',
              color: const Color(0xFF2E7D32),
            ),
            const SizedBox(height: 12),

            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.login_outlined,
                  title: 'Iniciar sesión',
                  subtitle: 'Accede a tu cuenta',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                ),
                _SettingsTile(
                  icon: Icons.person_add_outlined,
                  title: 'Crear cuenta',
                  subtitle: 'Regístrate como nuevo usuario',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                ),
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
                  onTap: () => _showComingSoon(context, 'Notificaciones'),
                ),
                _SettingsTile(
                  icon: Icons.color_lens_outlined,
                  title: 'Apariencia',
                  subtitle: 'Tema claro u oscuro',
                  onTap: () => _showComingSoon(context, 'Apariencia'),
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
                  onTap: () => _showComingSoon(context, 'Cerrar sesión'),
                  isLast: true,
                ),
              ],
            ),

            const SizedBox(height: 40),

            // ── Versión ───────────────────────────────────────────────
            const Center(
              child: Text(
                'App Finanzas v1.0.0',
                style: TextStyle(fontSize: 11, color: Color(0xFFCCCCCC)),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
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
                    color: iconColor ?? const Color(0xFF1A1A2E)),
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
                          color: titleColor ?? const Color(0xFF1A1A2E),
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showArrow)
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Color(0xFFCCCCCC),
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
              height: 1,
              indent: 54,
              endIndent: 18,
              color: Color(0xFFF0F0F0)),
      ],
    );
  }
}
