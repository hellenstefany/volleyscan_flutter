import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Emulador Android: 10.0.2.2 | Celular físico: IP de tu PC
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  Future<List<dynamic>> obtenerRegistros(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint/');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('No se pudo conectar a Django: $e');
    }
  }

  Future<bool> crearRegistro(
    String endpoint,
    Map<String, dynamic> datos,
  ) async {
    final url = Uri.parse('$baseUrl/$endpoint/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(datos),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al guardar en Django: $e');
    }
  }
}
