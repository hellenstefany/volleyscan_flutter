import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:volleyscan_mobile/models/equipo.dart';

// ════════════════════════════════════════════════════════════════
//  AJUSTA ESTO A TU API (equivale a lib/equipos/api.js en Next)
// ════════════════════════════════════════════════════════════════
const _baseUrl = 'TU_URL_BASE_API'; // ej. 'http://localhost:4000/api'
const _tokenKey = 'token'; // clave con la que guardas el token al hacer login

const _rutaListar = '/equipos'; // GET   listarEquipos
const _rutaMisInvitaciones = '/equipos/invitaciones'; // GET   misInvitaciones
const _rutaCrear = '/equipos'; // POST  crearEquipo
String _rutaResponder(String id, String accion) =>
    '/equipos/invitaciones/$id/$accion'; // POST  responderInvitacion
// ════════════════════════════════════════════════════════════════

/// Resultado de una llamada: o trae datos, o trae un mensaje de error.
class ApiResult<T> {
  final bool ok;
  final T? data;
  final String error;
  const ApiResult.ok(this.data) : ok = true, error = '';
  const ApiResult.fail(this.error) : ok = false, data = null;
}

class EquiposService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: _tokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ApiResult<dynamic>> _send(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    try {
      final uri = Uri.parse('$_baseUrl$path');
      final headers = await _headers();
      final res = method == 'GET'
          ? await http.get(uri, headers: headers)
          : await http.post(
              uri,
              headers: headers,
              body: jsonEncode(body ?? {}),
            );

      dynamic decoded;
      if (res.body.isNotEmpty) {
        try {
          decoded = jsonDecode(utf8.decode(res.bodyBytes));
        } catch (_) {}
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        // Acepta tanto [..] como {"data": [..]}
        final data = (decoded is Map && decoded.containsKey('data'))
            ? decoded['data']
            : decoded;
        return ApiResult.ok(data);
      }

      String msg = 'Error ${res.statusCode}';
      if (decoded is Map) {
        msg = '${decoded['message'] ?? decoded['error'] ?? msg}';
      }
      return ApiResult.fail(msg);
    } catch (_) {
      return const ApiResult.fail(
        'No se pudo conectar con el servidor. Revisa tu conexión.',
      );
    }
  }

  Future<ApiResult<List<Equipo>>> listarEquipos() async {
    final r = await _send('GET', _rutaListar);
    if (!r.ok) return ApiResult.fail(r.error);
    final lista = (r.data as List? ?? [])
        .map((e) => Equipo.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    return ApiResult.ok(lista);
  }

  Future<ApiResult<List<Invitacion>>> misInvitaciones() async {
    final r = await _send('GET', _rutaMisInvitaciones);
    if (!r.ok) return ApiResult.fail(r.error);
    final lista = (r.data as List? ?? [])
        .map((e) => Invitacion.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    return ApiResult.ok(lista);
  }

  Future<ApiResult<void>> crearEquipo({
    required String nombre,
    String categoria = '',
    String temporada = '',
  }) async {
    final r = await _send('POST', _rutaCrear, {
      'nombre': nombre.trim(),
      'categoria': categoria.trim(),
      'temporada': temporada.trim(),
    });
    return r.ok ? const ApiResult.ok(null) : ApiResult.fail(r.error);
  }

  /// [accion] es 'aceptar' o 'rechazar'.
  Future<ApiResult<void>> responderInvitacion(String id, String accion) async {
    final r = await _send('POST', _rutaResponder(id, accion));
    return r.ok ? const ApiResult.ok(null) : ApiResult.fail(r.error);
  }
}
