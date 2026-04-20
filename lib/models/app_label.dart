import 'package:flutter/material.dart';

/// Modelo de etiqueta con nombre y color personalizables.
class AppLabel {
  String name;
  Color color;

  AppLabel({required this.name, required this.color});
}

/// Lista global de etiquetas compartida en toda la app.
/// Se puede leer y modificar desde cualquier pantalla.
final List<AppLabel> globalLabels = [
  AppLabel(name: 'Alimentación', color: const Color(0xFFEF5350)),
  AppLabel(name: 'Transporte', color: const Color(0xFF42A5F5)),
  AppLabel(name: 'Salario', color: const Color(0xFF66BB6A)),
  AppLabel(name: 'Entretenimiento', color: const Color(0xFFAB47BC)),
  AppLabel(name: 'Salud', color: const Color(0xFF26C6DA)),
  AppLabel(name: 'Servicios', color: const Color(0xFFFF7043)),
  AppLabel(name: 'Educación', color: const Color(0xFF8D6E63)),
  AppLabel(name: 'Ahorro', color: const Color(0xFF78909C)),
];

/// Paleta de colores disponibles para seleccionar en el selector.
const List<Color> labelColorPalette = [
  Color(0xFFEF5350),
  Color(0xFFEC407A),
  Color(0xFFAB47BC),
  Color(0xFF7E57C2),
  Color(0xFF42A5F5),
  Color(0xFF26C6DA),
  Color(0xFF26A69A),
  Color(0xFF66BB6A),
  Color(0xFFD4E157),
  Color(0xFFFFCA28),
  Color(0xFFFFA726),
  Color(0xFFFF7043),
  Color(0xFF8D6E63),
  Color(0xFF78909C),
  Color(0xFF1A1A2E),
  Color(0xFF455A64),
];
