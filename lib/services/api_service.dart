import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/app_label.dart';

/// Servicio centralizado para todas las llamadas a la API REST.
class ApiService {
  static const _base = 'http://localhost:3000/api';

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── Transacciones ─────────────────────────────────────────────────────────

  /// GET /api/transactions — obtener todas las transacciones del usuario.
  Future<List<Transaction>> getTransactions() async {
    final response = await http.get(
      Uri.parse('$_base/transactions'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al obtener transacciones');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Transaction.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /api/transactions — crear una nueva transacción.
  Future<Transaction> addTransaction(Transaction t) async {
    final response = await http.post(
      Uri.parse('$_base/transactions'),
      headers: await _headers(),
      body: jsonEncode(t.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al guardar la transacción');
    }
    return Transaction.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// PUT /api/transactions/:id — actualizar monto y etiqueta.
  Future<void> updateTransaction(Transaction t) async {
    final response = await http.put(
      Uri.parse('$_base/transactions/${t.id}'),
      headers: await _headers(),
      body: jsonEncode({'label': t.label, 'amount': t.amount}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar la transacción');
    }
  }

  /// DELETE /api/transactions/:id — eliminar una transacción.
  Future<void> deleteTransaction(String id) async {
    final response = await http.delete(
      Uri.parse('$_base/transactions/$id'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la transacción');
    }
  }

  // ── Etiquetas ─────────────────────────────────────────────────────────────

  /// GET /api/labels — obtener todas las etiquetas del usuario.
  Future<List<AppLabel>> getLabels() async {
    final response = await http.get(
      Uri.parse('$_base/labels'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al obtener etiquetas');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => AppLabel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// POST /api/labels — crear una nueva etiqueta.
  Future<AppLabel> addLabel(AppLabel label) async {
    final response = await http.post(
      Uri.parse('$_base/labels'),
      headers: await _headers(),
      body: jsonEncode(label.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al guardar la etiqueta');
    }
    return AppLabel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// PUT /api/labels/:id — actualizar nombre y color.
  Future<void> updateLabel(AppLabel label) async {
    final response = await http.put(
      Uri.parse('$_base/labels/${label.id}'),
      headers: await _headers(),
      body: jsonEncode({'name': label.name, 'color': label.color.toARGB32()}),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar la etiqueta');
    }
  }

  /// DELETE /api/labels/:id — eliminar una etiqueta.
  Future<void> deleteLabel(String id) async {
    final response = await http.delete(
      Uri.parse('$_base/labels/$id'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la etiqueta');
    }
  }

  // ── Perfil ────────────────────────────────────────────────────────────────

  /// GET /api/profile — obtener datos del perfil.
  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$_base/profile'),
      headers: await _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al obtener perfil');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// PUT /api/profile — actualizar uno o varios campos del perfil.
  Future<void> updateProfile(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_base/profile'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar perfil');
    }
  }
}
