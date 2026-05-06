import 'dart:math';
import 'package:flutter/material.dart';

/// Modelo de etiqueta con nombre y color personalizables.
class AppLabel {
  final String id;
  String name;
  Color color;

  AppLabel({required this.id, required this.name, required this.color});

  /// Construir desde JSON devuelto por la API REST.
  factory AppLabel.fromJson(Map<String, dynamic> json) {
    return AppLabel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: Color(json['color'] as int),
    );
  }

  /// Serializar para enviar a la API REST.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color.toARGB32(),
      };

  /// Genera un ID único local para la etiqueta.
  static String generateId() {
    final rand = Random();
    return 'lbl_${List.generate(16, (_) => rand.nextInt(16).toRadixString(16)).join()}';
  }
}

/// Etiquetas por defecto (se copian a Firestore al crear cuenta).
final List<AppLabel> defaultLabels = [
  AppLabel(id: 'alimentacion', name: 'Alimentación', color: const Color(0xFFEF5350)),
  AppLabel(id: 'transporte', name: 'Transporte', color: const Color(0xFF42A5F5)),
  AppLabel(id: 'salario', name: 'Salario', color: const Color(0xFF66BB6A)),
  AppLabel(id: 'entretenimiento', name: 'Entretenimiento', color: const Color(0xFFAB47BC)),
  AppLabel(id: 'salud', name: 'Salud', color: const Color(0xFF26C6DA)),
  AppLabel(id: 'servicios', name: 'Servicios', color: const Color(0xFFFF7043)),
  AppLabel(id: 'educacion', name: 'Educación', color: const Color(0xFF8D6E63)),
  AppLabel(id: 'ahorro', name: 'Ahorro', color: const Color(0xFF78909C)),
];

/// Lista global en memoria (se usa como fallback mientras Firestore carga).
List<AppLabel> globalLabels = List.from(defaultLabels);

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
