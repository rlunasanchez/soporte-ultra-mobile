import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, String>> _getHeadersForDownload() async {
    final token = await _authService.getToken();
    return {'Authorization': 'Bearer $token'};
  }

  Future<Uint8List> downloadFile(String url) async {
    final headers = await _getHeadersForDownload();
    final response = await http
        .get(Uri.parse(url), headers: headers)
        .timeout(
          const Duration(seconds: 60),
          onTimeout: () => throw Exception('Timeout'),
        );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Error downloading: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> _request(
    Future<http.Response> Function(Map<String, String>) requestFn, {
    int retries = 2,
  }) async {
    for (int i = 0; i <= retries; i++) {
      try {
        final headers = await _getHeaders();
        final response = await requestFn(headers).timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw Exception('Timeout'),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          return {'success': true, 'data': jsonDecode(response.body)};
        } else if (response.statusCode == 502 && i < retries) {
          await Future.delayed(Duration(milliseconds: (i + 1) * 1000));
          continue;
        } else {
          return _handleError(response);
        }
      } catch (e) {
        if (i < retries) {
          await Future.delayed(Duration(milliseconds: (i + 1) * 1000));
        } else {
          return {'success': false, 'msg': 'Error de conexión: $e'};
        }
      }
    }
    return {'success': false, 'msg': 'Error de conexión'};
  }

  Future<Map<String, dynamic>> get(String url) async {
    return _request((headers) => http.get(Uri.parse(url), headers: headers));
  }

  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    return _request(
      (headers) =>
          http.post(Uri.parse(url), headers: headers, body: jsonEncode(body)),
    );
  }

  Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    return _request(
      (headers) =>
          http.put(Uri.parse(url), headers: headers, body: jsonEncode(body)),
    );
  }

  Future<Map<String, dynamic>> delete(String url) async {
    return _request((headers) => http.delete(Uri.parse(url), headers: headers));
  }

  Map<String, dynamic> _handleError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      return {'success': false, 'msg': data['msg'] ?? 'Error del servidor'};
    } catch (_) {
      return {
        'success': false,
        'msg': 'Error del servidor: ${response.statusCode}',
      };
    }
  }
}

class OrdenService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getOrdenes({
    int page = 1,
    int limit = 5,
    String? os,
    String? cliente,
    String? tecnico,
    String? estado,
    String? equipo,
    String? marca,
    String? modelo,
    String? fechaAsignacionDesde,
    String? fechaAsignacionHasta,
    String? fechaReparacionDesde,
    String? fechaReparacionHasta,
    String? fecha,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (os != null && os.isNotEmpty) queryParams['os'] = os;
    if (cliente != null && cliente.isNotEmpty) queryParams['cliente'] = cliente;
    if (tecnico != null && tecnico.isNotEmpty) queryParams['tecnico'] = tecnico;
    if (estado != null && estado.isNotEmpty) queryParams['estado'] = estado;
    if (equipo != null && equipo.isNotEmpty) queryParams['equipo'] = equipo;
    if (marca != null && marca.isNotEmpty) queryParams['marca'] = marca;
    if (modelo != null && modelo.isNotEmpty) queryParams['modelo'] = modelo;
    if (fechaAsignacionDesde != null)
      queryParams['fechaAsignacionDesde'] = fechaAsignacionDesde;
    if (fechaAsignacionHasta != null)
      queryParams['fechaAsignacionHasta'] = fechaAsignacionHasta;
    if (fechaReparacionDesde != null)
      queryParams['fechaReparacionDesde'] = fechaReparacionDesde;
    if (fechaReparacionHasta != null)
      queryParams['fechaReparacionHasta'] = fechaReparacionHasta;
    if (fecha != null) queryParams['fecha'] = fecha;

    final uri = Uri.parse(
      ApiConfig.ordenes,
    ).replace(queryParameters: queryParams);
    return await _api.get(uri.toString());
  }

  Future<Map<String, dynamic>> crearOrden(Map<String, dynamic> orden) async {
    return await _api.post(ApiConfig.ordenes, orden);
  }

  Future<Map<String, dynamic>> actualizarOrden(
    int id,
    Map<String, dynamic> orden,
  ) async {
    return await _api.put('${ApiConfig.ordenes}/$id', orden);
  }

  Future<Map<String, dynamic>> eliminarOrden(int id) async {
    return await _api.delete('${ApiConfig.ordenes}/$id');
  }

  Future<Map<String, dynamic>> getTecnicos() async {
    return await _api.get(ApiConfig.tecnicos);
  }

  Future<Map<String, dynamic>> getValoresFormulario() async {
    return await _api.get(ApiConfig.valoresFormulario);
  }

  Future<Map<String, dynamic>> getFiltrosValores() async {
    return await _api.get(ApiConfig.filtrosValores);
  }

  Future<Map<String, dynamic>> getExcel({Map<String, String>? filters}) async {
    final queryParams = filters ?? {};
    final uri = Uri.parse(
      ApiConfig.excel,
    ).replace(queryParameters: queryParams);
    return await _api.get(uri.toString());
  }

  Future<Map<String, dynamic>> getExcelCorreo({
    Map<String, String>? filters,
  }) async {
    final queryParams = filters ?? {};
    final uri = Uri.parse(
      ApiConfig.excelCorreo,
    ).replace(queryParameters: queryParams);
    return await _api.get(uri.toString());
  }

  Future<Map<String, dynamic>> getExcelRespaldo({
    Map<String, String>? filters,
  }) async {
    final queryParams = filters ?? {};
    final uri = Uri.parse(
      ApiConfig.excelRespaldo,
    ).replace(queryParameters: queryParams);
    return await _api.get(uri.toString());
  }

  Future<Map<String, dynamic>> getPdf({Map<String, String>? filters}) async {
    final queryParams = filters ?? {};
    final uri = Uri.parse(ApiConfig.pdf).replace(queryParameters: queryParams);
    return await _api.get(uri.toString());
  }

  Future<Uint8List> descargarExcel({Map<String, String>? filters}) async {
    final queryParams = filters ?? {};
    final uri = Uri.parse(
      ApiConfig.excel,
    ).replace(queryParameters: queryParams);
    return await _api.downloadFile(uri.toString());
  }

  Future<Uint8List> descargarExcelCorreo({Map<String, String>? filters}) async {
    final queryParams = filters ?? {};
    final uri = Uri.parse(
      ApiConfig.excelCorreo,
    ).replace(queryParameters: queryParams);
    return await _api.downloadFile(uri.toString());
  }

  Future<Uint8List> descargarExcelRespaldo({
    Map<String, String>? filters,
  }) async {
    final queryParams = filters ?? {};
    final uri = Uri.parse(
      ApiConfig.excelRespaldo,
    ).replace(queryParameters: queryParams);
    return await _api.downloadFile(uri.toString());
  }

  Future<Uint8List> descargarPdf({Map<String, String>? filters}) async {
    final queryParams = filters ?? {};
    final uri = Uri.parse(ApiConfig.pdf).replace(queryParameters: queryParams);
    return await _api.downloadFile(uri.toString());
  }
}

class UsuarioService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getUsuarios() async {
    return await _api.get(ApiConfig.usuarios);
  }

  Future<Map<String, dynamic>> crearUsuario(
    Map<String, dynamic> usuario,
  ) async {
    return await _api.post(ApiConfig.registrar, usuario);
  }

  Future<Map<String, dynamic>> actualizarUsuario(
    int id,
    Map<String, dynamic> usuario,
  ) async {
    return await _api.put(
      '${ApiConfig.usuarios}/actualizar-usuario/$id',
      usuario,
    );
  }

  Future<Map<String, dynamic>> eliminarUsuario(int id) async {
    return await _api.delete('${ApiConfig.usuarios}/eliminar-usuario/$id');
  }

  Future<Map<String, dynamic>> activarUsuario(int id, bool activo) async {
    return await _api.put('${ApiConfig.usuarios}/activar-usuario/$id', {
      'activo': activo,
    });
  }

  Future<Map<String, dynamic>> resetearPassword(
    int id,
    String nuevaPassword,
  ) async {
    return await _api.put('${ApiConfig.usuarios}/resetear-password/$id', {
      'nuevaPassword': nuevaPassword,
    });
  }
}

class RetiroService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getRetiros({
    int page = 1,
    int limit = 5,
    String? fechaDesde,
    String? fechaHasta,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (fechaDesde != null) queryParams['fechaDesde'] = fechaDesde;
    if (fechaHasta != null) queryParams['fechaHasta'] = fechaHasta;

    final uri = Uri.parse(
      ApiConfig.retiros,
    ).replace(queryParameters: queryParams);
    return await _api.get(uri.toString());
  }

  Future<Map<String, dynamic>> crearRetiro(Map<String, dynamic> retiro) async {
    return await _api.post(ApiConfig.retiros, retiro);
  }

  Future<Map<String, dynamic>> actualizarRetiro(
    int id,
    Map<String, dynamic> retiro,
  ) async {
    return await _api.put('${ApiConfig.retiros}/$id', retiro);
  }

  Future<Map<String, dynamic>> eliminarRetiro(int id) async {
    return await _api.delete('${ApiConfig.retiros}/$id');
  }

  Future<Uint8List> descargarExcel({
    String? fechaDesde,
    String? fechaHasta,
  }) async {
    final queryParams = <String, String>{};
    if (fechaDesde != null) queryParams['fechaDesde'] = fechaDesde;
    if (fechaHasta != null) queryParams['fechaHasta'] = fechaHasta;
    final uri = Uri.parse(
      ApiConfig.retirosExcel,
    ).replace(queryParameters: queryParams);
    return await _api.downloadFile(uri.toString());
  }
}
