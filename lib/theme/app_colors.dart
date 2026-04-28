import 'package:flutter/material.dart';

extension AppColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Fondo principal de Scaffold
  Color get bg => isDark ? const Color(0xFF0F0F14) : const Color(0xFFF7F8FA);

  /// Fondo de tarjetas / contenedores
  Color get card => isDark ? const Color(0xFF1C1C28) : Colors.white;

  /// Color de texto principal
  Color get textMain => isDark ? const Color(0xFFE8E8F0) : const Color(0xFF1A1A2E);

  /// Color de texto secundario / subtítulos
  Color get textSub => isDark ? const Color(0xFF8888AA) : const Color(0xFF888888);

  /// Relleno de campos de entrada
  Color get inputFill => isDark ? const Color(0xFF252533) : const Color(0xFFF5F5F5);

  /// Divisores y bordes suaves
  Color get divider => isDark ? const Color(0xFF2A2A3C) : const Color(0xFFF0F0F0);

  /// Handle del bottom sheet
  Color get handle => isDark ? const Color(0xFF44445A) : const Color(0xFFDDDDDD);

  /// Track de la gráfica de dona
  Color get donutTrack => isDark ? const Color(0xFF2A2A3C) : const Color(0xFFEEEEEE);

  /// Sombra de tarjetas
  Color get shadow => isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05);
}
