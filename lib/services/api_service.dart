import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Chrome (Flutter Web):  http://127.0.0.1:8000/api
  // Emulador Android:      http://10.0.2.2:8000/api
  // Celular físico:        http://IP_DE_TU_PC:8000/api
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static const _storage = FlutterSecureStorage();

  // ---------- Token ----------
  static Future<String?> getToken() => _storage.read(key: 'access');
  static Future<void> saveToken(String t) =>
      _storage.write(key: 'access', value: t);
  static Future<void> logout() => _storage.delete(key: 'access');

  static Future<Map<String, String>> _headers() async {
    final t = await getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (t != null) 'Authorization': 'Bearer $t',
    };
  }

  static dynamic _handle(http.Response r) {
    final body = r.body.isEmpty ? null : jsonDecode(utf8.decode(r.bodyBytes));
    if (r.statusCode >= 200 && r.statusCode < 300) return body;
    final msg = (body is Map && body['detail'] != null)
        ? body['detail']
        : r.body;
    throw Exception(msg.toString());
  }

  // ---------- Métodos genéricos (la ruta se escribe completa, con o sin "/") ----------
  Future<dynamic> get(String path) async => _handle(
    await http.get(Uri.parse('$baseUrl$path'), headers: await _headers()),
  );

  Future<dynamic> post(String path, Map<String, dynamic> body) async => _handle(
    await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    ),
  );

  Future<dynamic> put(String path, Map<String, dynamic> body) async => _handle(
    await http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    ),
  );

  Future<dynamic> delete(String path) async => _handle(
    await http.delete(Uri.parse('$baseUrl$path'), headers: await _headers()),
  );

  // ---------- Compatibilidad con tus métodos anteriores ----------
  // endpoint = 'usuario/rutinas'  ->  GET /api/usuario/rutinas/
  Future<List<dynamic>> obtenerRegistros(String endpoint) async =>
      (await get('/$endpoint/')) as List<dynamic>;

  Future<bool> crearRegistro(
    String endpoint,
    Map<String, dynamic> datos,
  ) async {
    await post('/$endpoint/', datos);
    return true;
  }

  // ---------- Auth ----------
  Future<void> login(String email, String password) async {
    final data = await post('/auth/login', {
      'email': email,
      'password': password,
    });
    await saveToken(data['access']);
  }

  Future<void> registro(
    String nombre,
    String apellido,
    String email,
    String password,
  ) async {
    final data = await post('/auth/registro', {
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'password': password,
    });
    await saveToken(data['access']);
  }

  // ---------- Perfil ----------
  Future<Map<String, dynamic>> perfil() async =>
      Map<String, dynamic>.from(await get('/usuario/perfil/'));
}
