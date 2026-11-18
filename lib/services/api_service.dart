import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/coach_link_data.dart';
import '../models/my_level_data.dart';
import '../models/my_matches_data.dart';
import '../models/my_teams_data.dart';
import '../models/notification_data.dart';
import '../models/routine_data.dart';
import '../models/schedule_data.dart';
import '../models/content_data.dart';
import '../models/dashboard_data.dart';
import '../models/device_data.dart';
import '../models/preferences_data.dart';
import '../models/profile_data.dart';
import '../models/progreso_atleta_data.dart';
import '../widgets/entrenador/dashboard/dashboard_models.dart';
import '../screens/login_screen.dart';
import '../theme/app_theme.dart';

/// Excepción estructurada para errores de la API (equivalente a `ErrorApi` / `ApiError` en Next).
class ApiException implements Exception {
  /// Código HTTP de la respuesta, o `0` cuando no hubo conexión con el servidor.
  final int statusCode;

  /// Mensaje legible (extraído de `detail` del backend o mensaje por defecto).
  final String message;

  /// Cuerpo completo decodificado de la respuesta (por ejemplo errores por campo).
  final dynamic data;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.data,
  });

  bool get isNoConnection => statusCode == 0;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isRateLimited => statusCode == 429;
  bool get isInvalidCredentials =>
      statusCode == 400 || statusCode == 401 || statusCode == 403;

  @override
  String toString() => message;
}

class ApiService {
  /// Permite sobreescribir la URL base al compilar/ejecutar:
  /// `flutter run --dart-define=API_URL=http://192.168.1.50:8000/api`
  static const String _envBaseUrl = String.fromEnvironment('API_URL');

  /// Permite sobreescribir la URL del microservicio de Chat IA:
  /// `flutter run --dart-define=AI_API_URL=http://192.168.1.50:8010`
  static const String _envAiBaseUrl = String.fromEnvironment(
    'AI_API_URL',
    defaultValue: '',
  );

  /// URL base:
  /// - Si se pasa `--dart-define=API_URL=...`, usa ese valor.
  /// - En Android (emulador): `http://10.0.2.2:8000/api`
  /// - En Web / Windows / iOS Simulator: `http://127.0.0.1:8000/api`
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl.endsWith('/')
          ? _envBaseUrl.substring(0, _envBaseUrl.length - 1)
          : _envBaseUrl;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  /// URL base del servicio de Chat IA (`:8010` en Next `src/app/services/api.js`):
  /// - Si se pasa `--dart-define=AI_API_URL=...`, usa ese valor.
  /// - En Android (emulador): `http://10.0.2.2:8010`
  /// - En Web / Windows / iOS Simulator: `http://127.0.0.1:8010`
  static String get aiBaseUrl {
    if (_envAiBaseUrl.isNotEmpty) {
      return _envAiBaseUrl.endsWith('/')
          ? _envAiBaseUrl.substring(0, _envAiBaseUrl.length - 1)
          : _envAiBaseUrl;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8010';
    }
    return 'http://127.0.0.1:8010';
  }

  /// Key global de navegación para redirigir al Login cuando vence el JWT (401).
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access';
  static const _userKey = 'usuario';
  static const _timeout = Duration(seconds: 15);
  static bool _isHandlingUnauthorized = false;

  // ---------- Sesión segura (JWT + Usuario) ----------

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<void> saveUsuario(Map<String, dynamic> usuario) =>
      _storage.write(key: _userKey, value: jsonEncode(usuario));

  static Future<Map<String, dynamic>?> getUsuario() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveSession(Map<String, dynamic> data) async {
    final access = data['access']?.toString();
    if (access != null && access.isNotEmpty) {
      await saveToken(access);
    }
    final usuario = data['usuario'];
    if (usuario is Map) {
      await saveUsuario(Map<String, dynamic>.from(usuario));
    }
  }

  /// Actualiza parcialmente el mapa `usuario` guardado en `flutter_secure_storage`
  /// para que el Dashboard y el Drawer reflejen cambios de nombre, email o foto.
  static Future<void> updateStoredUsuario(Map<String, dynamic> partial) async {
    final current = await getUsuario() ?? <String, dynamic>{};
    current.addAll(partial);
    await saveUsuario(current);
  }

  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  // ---------- Cabeceras y manejo de respuestas ----------

  static Future<Map<String, String>> _headers({bool includeAuth = true}) async {
    final token = includeAuth ? await getToken() : null;
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _decodeBody(http.Response r) {
    if (r.statusCode == 204 || r.bodyBytes.isEmpty) return null;
    final text = utf8.decode(r.bodyBytes);
    if (text.trim().isEmpty) return null;
    try {
      return jsonDecode(text);
    } catch (_) {
      return text;
    }
  }

  static String _extractErrorMessage(int statusCode, dynamic body) {
    if (body is Map) {
      if (body['detail'] != null && body['detail'].toString().isNotEmpty) {
        return body['detail'].toString();
      }
      if (body['non_field_errors'] is List &&
          (body['non_field_errors'] as List).isNotEmpty) {
        return (body['non_field_errors'] as List).first.toString();
      }
      for (final entry in body.entries) {
        final val = entry.value;
        if (val is List && val.isNotEmpty) {
          return val.first.toString();
        }
        if (val is String && val.isNotEmpty) {
          return val;
        }
      }
    }
    if (body is String && body.isNotEmpty && !body.trimLeft().startsWith('<')) {
      return body;
    }
    if (statusCode == 413) {
      return 'La imagen no puede superar 2 MB.';
    }
    if (statusCode == 429) {
      return 'Demasiados intentos. Espera un minuto.';
    }
    if (statusCode == 401) {
      return 'Sesión expirada o credenciales inválidas.';
    }
    if (statusCode == 403) {
      return 'No tienes permiso para realizar esta acción.';
    }
    return 'Error del servidor (código $statusCode).';
  }

  static Future<dynamic> _handleResponse(
    http.Response r, {
    required bool hadAuthToken,
  }) async {
    final body = _decodeBody(r);
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return body;
    }

    // Si la petición llevaba un JWT y el backend responde 401 (token vencido o sesión cerrada),
    // limpiamos el almacenamiento seguro y redirigimos al Login una sola vez.
    if (r.statusCode == 401 && hadAuthToken && !_isHandlingUnauthorized) {
      final storedToken = await getToken();
      if (storedToken != null && storedToken.isNotEmpty) {
        _isHandlingUnauthorized = true;
        try {
          await logout();
          final navState = navigatorKey.currentState;
          final ctx = navigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            showAppToast(
              ctx,
              'Tu sesión ha expirado. Inicia sesión nuevamente.',
              type: 'error',
            );
          }
          navState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        } finally {
          _isHandlingUnauthorized = false;
        }
      }
    }

    throw ApiException(
      statusCode: r.statusCode,
      message: _extractErrorMessage(r.statusCode, body),
      data: body,
    );
  }

  Future<dynamic> _sendRequest(
    Future<http.Response> Function(Map<String, String> headers) requestFn, {
    bool includeAuth = true,
  }) async {
    final headers = await _headers(includeAuth: includeAuth);
    final hadAuthToken = headers.containsKey('Authorization');

    try {
      final response = await requestFn(headers).timeout(_timeout);
      return await _handleResponse(response, hadAuthToken: hadAuthToken);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        statusCode: 0,
        message:
            'Tiempo de espera agotado al conectar con el servidor. Verifica que esté encendido.',
      );
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        message:
            'No se pudo conectar con el servidor. Revisa tu conexión y que el servidor esté encendido.',
      );
    } on http.ClientException {
      throw const ApiException(
        statusCode: 0,
        message:
            'No se pudo conectar con el servidor. Revisa que esté encendido y accesible.',
      );
    } catch (_) {
      throw const ApiException(
        statusCode: 0,
        message: 'No se pudo conectar con el servidor.',
      );
    }
  }

  // ---------- Métodos HTTP genéricos (con o sin "/" según el endpoint) ----------

  Future<dynamic> get(String path, {bool includeAuth = true}) => _sendRequest(
        (headers) => http.get(Uri.parse('$baseUrl$path'), headers: headers),
        includeAuth: includeAuth,
      );

  Future<dynamic> post(
    String path,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) =>
      _sendRequest(
        (headers) => http.post(
          Uri.parse('$baseUrl$path'),
          headers: headers,
          body: jsonEncode(body),
        ),
        includeAuth: includeAuth,
      );

  Future<dynamic> put(
    String path,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) =>
      _sendRequest(
        (headers) => http.put(
          Uri.parse('$baseUrl$path'),
          headers: headers,
          body: jsonEncode(body),
        ),
        includeAuth: includeAuth,
      );

  Future<dynamic> patch(
    String path,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) =>
      _sendRequest(
        (headers) => http.patch(
          Uri.parse('$baseUrl$path'),
          headers: headers,
          body: jsonEncode(body),
        ),
        includeAuth: includeAuth,
      );

  Future<dynamic> delete(String path, {bool includeAuth = true}) =>
      _sendRequest(
        (headers) => http.delete(Uri.parse('$baseUrl$path'), headers: headers),
        includeAuth: includeAuth,
      );

  // ---------- Compatibilidad con métodos anteriores ----------

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

  /// Inicia sesión contra `POST /api/auth/login` (sin barra final),
  /// guarda `access` y `usuario` en `flutter_secure_storage` y devuelve el mapa `usuario`.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await post(
      '/auth/login',
      {
        'email': email.trim(),
        'password': password,
      },
      includeAuth: false,
    );
    final map = Map<String, dynamic>.from(data as Map);
    await saveSession(map);
    return Map<String, dynamic>.from((map['usuario'] as Map?) ?? const {});
  }

  /// Obtiene el resumen del usuario actual desde `GET /api/auth/me`.
  Future<Map<String, dynamic>> me() async {
    final data = await get('/auth/me');
    final usuario = Map<String, dynamic>.from(data as Map);
    await saveUsuario(usuario);
    return usuario;
  }

  /// Registra un nuevo atleta contra `POST /api/auth/registro`,
  /// guarda la sesión y devuelve el mapa `usuario`.
  Future<Map<String, dynamic>> registro(
    String nombre,
    String apellido,
    String email,
    String password,
  ) async {
    final data = await post(
      '/auth/registro',
      {
        'nombre': nombre.trim(),
        'apellido': apellido.trim(),
        'email': email.trim(),
        'password': password,
      },
      includeAuth: false,
    );
    final map = Map<String, dynamic>.from(data as Map);
    await saveSession(map);
    return Map<String, dynamic>.from((map['usuario'] as Map?) ?? const {});
  }

  /// Preparado para inicio de sesión con Google (`POST /api/auth/google`).
  Future<Map<String, dynamic>> loginWithGoogle(String credential) async {
    final data = await post(
      '/auth/google',
      {'credential': credential},
      includeAuth: false,
    );
    final map = Map<String, dynamic>.from(data as Map);
    await saveSession(map);
    return Map<String, dynamic>.from((map['usuario'] as Map?) ?? const {});
  }

  /// Solicita el enlace de recuperación de contraseña (`POST /api/auth/recuperar`).
  /// El backend responde siempre 200 con `{ "mensaje": "..." }` exista o no la cuenta.
  Future<String> recuperarPassword(String email) async {
    final data = await post(
      '/auth/recuperar',
      {'email': email.trim().toLowerCase()},
      includeAuth: false,
    );
    if (data is Map && data['mensaje'] != null) {
      return data['mensaje'].toString();
    }
    return 'Si el correo está registrado, te enviamos un enlace para restablecer tu contraseña.';
  }

  /// Restablece la contraseña usando el token enviado por correo (`POST /api/auth/restablecer`).
  Future<String> restablecerPassword({
    required String token,
    required String passwordNueva,
  }) async {
    final data = await post(
      '/auth/restablecer',
      {
        'token': token.trim(),
        'password_nueva': passwordNueva,
      },
      includeAuth: false,
    );
    if (data is Map && data['mensaje'] != null) {
      return data['mensaje'].toString();
    }
    return 'Contraseña actualizada. Ya puedes iniciar sesión.';
  }

  /// Cierra la sesión en el servidor (`/api/usuario/dispositivos/cerrar-actual/`)
  /// y limpia el almacenamiento seguro local.
  Future<void> cerrarSesionCompleta() async {
    final token = await getToken();
    await logout();
    if (token != null && token.isNotEmpty) {
      try {
        await http
            .post(
              Uri.parse('$baseUrl/usuario/dispositivos/cerrar-actual/'),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $token',
              },
              body: '{}',
            )
            .timeout(_timeout);
      } catch (_) {
        // Si el token ya venció o no hay red, ya se limpió localmente.
      }
    }
  }

  // ---------- Perfil y Dashboard de Usuario ----------

  Future<Map<String, dynamic>> perfil() async =>
      Map<String, dynamic>.from(await get('/usuario/perfil/') as Map);

  /// Obtiene los datos del perfil (`GET /api/usuario/perfil/`) y sincroniza la sesión local.
  Future<ProfileData> obtenerPerfil() async {
    final raw = Map<String, dynamic>.from(await get('/usuario/perfil/') as Map);
    final data = ProfileData.fromJson(raw);
    await updateStoredUsuario({
      'nombre': data.nombre,
      'apellido': data.apellido,
      'email': data.email,
      'nivel': data.nivel,
      'foto_url': data.fotoUrl,
    });
    return data;
  }

  /// Actualiza el perfil (`PUT /api/usuario/perfil/`) enviando solo los campos modificados.
  Future<ProfileData> actualizarPerfil(Map<String, dynamic> cambios) async {
    final raw = Map<String, dynamic>.from(
      await put('/usuario/perfil/', cambios) as Map,
    );
    final data = ProfileData.fromJson(raw);
    await updateStoredUsuario({
      'nombre': data.nombre,
      'apellido': data.apellido,
      'email': data.email,
      'nivel': data.nivel,
      'foto_url': data.fotoUrl,
    });
    return data;
  }

  /// Cambia la contraseña (`PUT /api/usuario/perfil/password/`).
  Future<String> cambiarPasswordPerfil({
    required String passwordActual,
    required String passwordNueva,
  }) async {
    final data = await put('/usuario/perfil/password/', {
      'password_actual': passwordActual,
      'password_nueva': passwordNueva,
    });
    if (data is Map && data['mensaje'] != null) {
      return data['mensaje'].toString();
    }
    return 'Contraseña actualizada.';
  }

  /// Sube la foto de perfil (`POST /api/usuario/perfil/foto/`) vía `multipart/form-data` (campo `"foto"`).
  Future<String?> subirFotoPerfil({
    required Uint8List bytes,
    required String filename,
  }) async {
    return _sendRequest((headers) async {
      final uri = Uri.parse('$baseUrl/usuario/perfil/foto/');
      final req = http.MultipartRequest('POST', uri);
      if (headers['Authorization'] != null) {
        req.headers['Authorization'] = headers['Authorization']!;
      }
      req.headers['Accept'] = 'application/json';
      req.files.add(
        http.MultipartFile.fromBytes('foto', bytes, filename: filename),
      );
      final streamed = await req.send();
      return http.Response.fromStream(streamed);
    }).then((body) async {
      final fotoUrl = (body is Map) ? body['foto_url']?.toString() : null;
      await updateStoredUsuario({'foto_url': fotoUrl});
      return fotoUrl;
    });
  }

  /// Quita la foto de perfil (`DELETE /api/usuario/perfil/foto/`).
  Future<void> eliminarFotoPerfil() async {
    await delete('/usuario/perfil/foto/');
    await updateStoredUsuario({'foto_url': null});
  }

  /// Obtiene las preferencias del usuario (`GET /api/usuario/configuracion/`).
  Future<PreferencesData> obtenerConfiguracion() async {
    final raw = Map<String, dynamic>.from(
      await get('/usuario/configuracion/') as Map,
    );
    return PreferencesData.fromJson(raw);
  }

  /// Guarda las preferencias del usuario (`PUT /api/usuario/configuracion/`).
  Future<PreferencesData> actualizarConfiguracion(PreferencesData prefs) async {
    final raw = Map<String, dynamic>.from(
      await put('/usuario/configuracion/', prefs.toJson()) as Map,
    );
    return PreferencesData.fromJson(raw);
  }

  // ---------- Dispositivos conectados (/api/usuario/dispositivos/) ----------

  /// Lista los dispositivos con sesión activa (`GET /api/usuario/dispositivos/`).
  Future<List<ConnectedDevice>> listarDispositivos() async {
    final raw = await get('/usuario/dispositivos/');
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((m) => ConnectedDevice.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  /// Cierra la sesión de otro dispositivo (`DELETE /api/usuario/dispositivos/<id>/`).
  Future<void> cerrarDispositivo(int id) async {
    await delete('/usuario/dispositivos/$id/');
  }

  /// Cierra todas las sesiones excepto la del dispositivo actual
  /// (`POST /api/usuario/dispositivos/cerrar-otros/`) y devuelve la cantidad `cerrados`.
  Future<int> cerrarOtrosDispositivos() async {
    final raw = await post('/usuario/dispositivos/cerrar-otros/', const {});
    if (raw is Map && raw['cerrados'] is num) {
      return (raw['cerrados'] as num).toInt();
    }
    return 0;
  }

  /// Obtiene los datos principales del dashboard del atleta (`GET /api/usuario/dashboard/`).
  Future<DashboardResponse> dashboardUsuario() async {
    final data = await get('/usuario/dashboard/');
    return DashboardResponse.fromJson(Map<String, dynamic>.from(data as Map));
  }

  /// Obtiene el progreso completo del deportista (`GET /api/ia/progreso?tz=...`).
  /// `tz` equivale a `new Date().getTimezoneOffset()` en JS (minutos de desfase UTC -> local).
  Future<ProgresoAtletaResponse> progresoAtleta({int? tzOffsetMinutes}) async {
    final tz = tzOffsetMinutes ?? -DateTime.now().timeZoneOffset.inMinutes;
    final data = await get('/ia/progreso?tz=$tz');
    return ProgresoAtletaResponse.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  /// Obtiene el contador de avisos/notificaciones sin leer (`GET /api/ia/avisos/contador`).
  Future<AvisosContadorResponse> contadorAvisos({bool todas = true}) async {
    final query = todas ? '?todas=1' : '';
    final data = await get('/ia/avisos/contador$query');
    if (data is Map) {
      return AvisosContadorResponse.fromJson(Map<String, dynamic>.from(data));
    }
    return const AvisosContadorResponse(noLeidas: 0);
  }

  /// Lista las notificaciones/avisos del usuario (`GET /api/ia/avisos`).
  Future<AvisosListResponse> listarAvisos({
    int limite = 100,
    bool todas = true,
    bool soloNoLeidas = false,
  }) async {
    final params = <String>[
      'limite=$limite',
      if (soloNoLeidas) 'soloNoLeidas=1',
      if (todas) 'todas=1',
    ];
    final data = await get('/ia/avisos?${params.join('&')}');
    if (data is Map) {
      return AvisosListResponse.fromJson(Map<String, dynamic>.from(data));
    }
    return const AvisosListResponse();
  }

  /// Marca un aviso como leído (`POST /api/ia/avisos/<id>/leida`).
  Future<int> marcarAvisoLeida(int id, {bool todas = true}) async {
    final query = todas ? '?todas=1' : '';
    final data = await post('/ia/avisos/$id/leida$query', const <String, dynamic>{});
    if (data is Map && data['noLeidas'] != null) {
      return int.tryParse(data['noLeidas'].toString()) ?? 0;
    }
    return 0;
  }

  /// Marca todos los avisos como leídos (`POST /api/ia/avisos/leer-todas`).
  Future<void> marcarTodosLosAvisosLeidos({bool todas = true}) async {
    final query = todas ? '?todas=1' : '';
    await post('/ia/avisos/leer-todas$query', const <String, dynamic>{});
  }

  /// Elimina un aviso (`DELETE /api/ia/avisos/<id>`).
  Future<void> eliminarAviso(int id) async {
    await delete('/ia/avisos/$id');
  }

  /// Elimina todos los avisos del usuario (`DELETE /api/ia/avisos`).
  Future<void> eliminarTodosLosAvisos({bool todas = true}) async {
    final query = todas ? '?todas=1' : '';
    await delete('/ia/avisos$query');
  }

  // ---------- Contenido Educativo ----------

  /// Obtiene el catálogo de videos educativos (`GET /api/usuario/contenido/`).
  /// Acepta opcionalmente `categoria` (`saque`, `recepcion`, `bloqueo`, `pose`, `preparacion`).
  Future<List<ContentVideo>> obtenerContenidos({String? categoria}) async {
    final cat = categoria?.trim();
    final query = (cat != null && cat.isNotEmpty && cat != 'all')
        ? '?categoria=${Uri.encodeQueryComponent(cat)}'
        : '';
    final data = await get('/usuario/contenido/$query');
    final List<dynamic> rawList;
    if (data is List) {
      rawList = data;
    } else if (data is Map) {
      rawList = (data['results'] ??
              data['items'] ??
              data['contenido'] ??
              const <dynamic>[])
          as List<dynamic>;
    } else {
      rawList = const <dynamic>[];
    }
    return rawList
        .whereType<Map>()
        .map((item) => ContentVideo.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  /// Obtiene el detalle de un video educativo (`GET /api/usuario/contenido/<id>/`).
  Future<ContentVideo> obtenerContenidoDetalle(int id) async {
    final data = await get('/usuario/contenido/$id/');
    return ContentVideo.fromJson(Map<String, dynamic>.from(data as Map));
  }

  // ---------- Mi Entrenador (Vínculos Atleta-Entrenador) ----------

  /// Obtiene el vínculo vigente del atleta o su último rechazo (`GET /api/ia/vinculos/mi-entrenador`).
  Future<MyCoachResponse> miEntrenador() async {
    final data = await get('/ia/vinculos/mi-entrenador');
    if (data is Map) {
      return MyCoachResponse.fromJson(Map<String, dynamic>.from(data));
    }
    return const MyCoachResponse();
  }

  /// Lista los entrenadores activos disponibles (`GET /api/ia/vinculos/entrenadores`).
  Future<List<CoachPerson>> listarEntrenadores({String? q}) async {
    final query = (q != null && q.trim().isNotEmpty)
        ? '?q=${Uri.encodeQueryComponent(q.trim())}'
        : '';
    final data = await get('/ia/vinculos/entrenadores$query');
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => CoachPerson.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return const <CoachPerson>[];
  }

  /// Envía una solicitud de vinculación a un entrenador (`POST /api/ia/vinculos/solicitudes`).
  Future<int?> solicitarEntrenador(int entrenadorId) async {
    final data = await post(
      '/ia/vinculos/solicitudes',
      {'entrenadorId': entrenadorId},
    );
    if (data is Map && data['id'] != null) {
      return int.tryParse(data['id'].toString());
    }
    return null;
  }

  /// Cancela una solicitud pendiente o finaliza el vínculo activo (`DELETE /api/ia/vinculos/mi-entrenador`).
  Future<void> cancelarOSalirEntrenador() async {
    await delete('/ia/vinculos/mi-entrenador');
  }

  // ---------- Mis Equipos (Deportista) ----------

  /// Lista los equipos activos del deportista (`GET /api/ia/mis-equipos`).
  Future<List<MyTeam>> misEquipos() async {
    final data = await get('/ia/mis-equipos');
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => MyTeam.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return const <MyTeam>[];
  }

  /// Lista las invitaciones pendientes dirigidas al correo del usuario (`GET /api/ia/invitaciones/mias`).
  Future<List<TeamInvitation>> misInvitaciones() async {
    final data = await get('/ia/invitaciones/mias');
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) =>
              TeamInvitation.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return const <TeamInvitation>[];
  }

  /// Acepta o rechaza una invitación pendiente (`POST /api/ia/invitaciones/<id>/<accion>`).
  Future<InvitationActionResult> responderInvitacion(
    int invitacionId,
    String accion,
  ) async {
    final data = await post(
      '/ia/invitaciones/$invitacionId/$accion',
      const <String, dynamic>{},
    );
    if (data is Map) {
      return InvitationActionResult.fromJson(Map<String, dynamic>.from(data));
    }
    return InvitationActionResult(
      estado: accion == 'aceptar' ? 'aceptada' : 'rechazada',
      equipoId: 0,
      equipo: '',
      tipo: 'deportista',
    );
  }

  // ---------- Horario (Agenda del deportista) ----------

  /// Obtiene la agenda del deportista en un rango de fechas (`GET /api/ia/mi-horario`).
  Future<List<ScheduleEvent>> miHorario({
    required String desde,
    required String hasta,
  }) async {
    final query =
        '?desde=${Uri.encodeQueryComponent(desde)}&hasta=${Uri.encodeQueryComponent(hasta)}';
    final data = await get('/ia/mi-horario$query');
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => ScheduleEvent.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return const <ScheduleEvent>[];
  }

  // ---------- Mis Partidos (Deportista) ----------

  /// Obtiene los partidos jugados del atleta y su acumulado (`GET /api/ia/mis-partidos`).
  Future<MyMatchesResponse> misPartidos() async {
    final data = await get('/ia/mis-partidos');
    if (data is Map) {
      return MyMatchesResponse.fromJson(Map<String, dynamic>.from(data));
    }
    return const MyMatchesResponse();
  }

  // ---------- Mis Rutinas (Deportista) ----------

  /// Lista las rutinas asignadas al atleta (`GET /api/usuario/rutinas/`).
  Future<List<RoutineSummary>> listarRutinas() async {
    final data = await get('/usuario/rutinas/');
    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) => RoutineSummary.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }
    return const <RoutineSummary>[];
  }

  /// Obtiene el detalle de una rutina con sus ejercicios (`GET /api/usuario/rutinas/<id>/`).
  Future<RoutineDetail> detalleRutina(int rutinaId) async {
    final data = await get('/usuario/rutinas/$rutinaId/');
    if (data is Map) {
      return RoutineDetail.fromJson(Map<String, dynamic>.from(data));
    }
    throw ApiException(
      statusCode: 0,
      message: 'No se pudo leer el detalle de la rutina.',
    );
  }

  /// Marca o desmarca un ejercicio como completado (`PUT /api/usuario/rutinas/<id>/ejercicios/<eid>/completar/`).
  Future<ToggleExerciseResult> completarEjercicio({
    required int rutinaId,
    required int ejercicioId,
    required bool completado,
  }) async {
    final data = await put(
      '/usuario/rutinas/$rutinaId/ejercicios/$ejercicioId/completar/',
      {'completado': completado},
    );
    if (data is Map) {
      return ToggleExerciseResult.fromJson(Map<String, dynamic>.from(data));
    }
    throw ApiException(
      statusCode: 0,
      message: 'Respuesta inesperada al actualizar el ejercicio.',
    );
  }

  // ---------- Mi Nivel (Deportista) ----------

  /// Obtiene el nivel actual, criterios de avance, revisiones e historial (`GET /api/ia/mi-nivel`).
  Future<MyLevelResponse> miNivel() async {
    final tzOffset = -DateTime.now().timeZoneOffset.inMinutes;
    final data = await get('/ia/mi-nivel?tz=$tzOffset');
    if (data is Map) {
      return MyLevelResponse.fromJson(Map<String, dynamic>.from(data));
    }
    return const MyLevelResponse();
  }

  // ---------- Panel de Entrenador ----------

  /// Obtiene el resumen del dashboard del entrenador (`GET /api/panel/dashboard`, sin barra final).
  Future<EntrenadorDashboardData> dashboardEntrenador() async {
    final data = await get('/panel/dashboard');
    if (data is Map) {
      return EntrenadorDashboardData.fromJson(Map<String, dynamic>.from(data));
    }
    throw const ApiException(
      statusCode: 0,
      message: 'No se pudo cargar el resumen del dashboard.',
    );
  }

  /// Crea una nueva sesión en el horario del entrenador (`POST /api/panel/horarios`, sin barra final).
  Future<Map<String, dynamic>> crearHorarioEntrenador({
    required String titulo,
    required String tipoEvento,
    required String fecha,
    required String horaInicio,
    required String horaFin,
    String? ubicacion,
    String? notas,
    String estado = 'programado',
  }) async {
    final data = await post('/panel/horarios', {
      'titulo': titulo.trim(),
      'tipo_evento': tipoEvento,
      'fecha': fecha,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
      'ubicacion': (ubicacion != null && ubicacion.trim().isNotEmpty)
          ? ubicacion.trim()
          : null,
      'notas': (notas != null && notas.trim().isNotEmpty) ? notas.trim() : null,
      'estado': estado,
    });
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return const <String, dynamic>{};
  }

  // ---------- Chat IA (Microservicio :8010) ----------

  /// Envía una consulta al entrenador virtual (`POST $aiBaseUrl/chat`).
  Future<String> enviarMensajeChatIA(String mensaje) async {
    const aiTimeout = Duration(seconds: 30);
    try {
      final response = await http
          .post(
            Uri.parse('$aiBaseUrl/chat'),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'mensaje': mensaje}),
          )
          .timeout(aiTimeout);

      final body = _decodeBody(response);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (body is Map && body['respuesta'] != null) {
          return body['respuesta'].toString();
        }
        throw const ApiException(
          statusCode: 0,
          message: 'Respuesta inesperada de VolleyScan AI.',
        );
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: _extractErrorMessage(response.statusCode, body),
        data: body,
      );
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        statusCode: 0,
        message:
            'Tiempo de espera agotado al conectar con VolleyScan AI (:8010).',
      );
    } on SocketException {
      throw const ApiException(
        statusCode: 0,
        message:
            'No se pudo conectar con VolleyScan AI. Verifica que el servicio (:8010) esté encendido.',
      );
    } on http.ClientException {
      throw const ApiException(
        statusCode: 0,
        message:
            'No se pudo conectar con VolleyScan AI. Verifica que el servicio (:8010) esté encendido.',
      );
    } catch (_) {
      throw const ApiException(
        statusCode: 0,
        message: 'No se pudo conectar con VolleyScan AI.',
      );
    }
  }

  /// Convierte URL relativa `/media/...` en absoluta respecto al host del backend.
  static String? resolveMediaUrl(String? rawUrl) {
    if (rawUrl == null) return null;
    final url = rawUrl.trim();
    if (url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final apiBase = baseUrl;
    final hostBase = apiBase.endsWith('/api')
        ? apiBase.substring(0, apiBase.length - 4)
        : apiBase;
    return url.startsWith('/') ? '$hostBase$url' : '$hostBase/$url';
  }
}

