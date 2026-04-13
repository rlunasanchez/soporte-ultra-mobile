import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _rolKey = 'auth_rol';

  String _decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length > 1) {
        final payload = parts[1];
        final padded = payload.padRight(
          payload.length + (4 - payload.length % 4) % 4,
          '=',
        );
        final decoded = utf8.decode(
          base64Decode(padded.replaceAll('-', '+').replaceAll('_', '/')),
        );
        return decoded;
      }
    } catch (e) {
      // Ignore decoding errors
    }
    return '{}';
  }

  Future<Map<String, dynamic>> login(String usuario, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'usuario': usuario, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        final decodedJson = _decodeToken(token);
        final decoded = jsonDecode(decodedJson);
        final rol = decoded['rol'] ?? 'tecnico';

        await _saveToken(token);
        await _saveUser(usuario);
        await _saveRol(rol);

        return {
          'success': true,
          'token': token,
          'usuario': usuario,
          'rol': rol,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'msg': data['msg'] ?? 'Error de autenticación',
        };
      }
    } catch (e) {
      return {'success': false, 'msg': 'Error de conexión: $e'};
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUser(String usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, usuario);
  }

  Future<void> _saveRol(String rol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_rolKey, rol);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  Future<String?> getRol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_rolKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_rolKey);
  }
}
