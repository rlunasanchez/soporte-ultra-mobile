class ApiConfig {
  static const String baseUrl =
      'https://sistema-soporte-ultra.onrender.com/api';

  static const String login = '$baseUrl/auth/login';
  static const String registrar = '$baseUrl/auth/registrar';
  static const String cambiarPassword = '$baseUrl/auth/cambiar-password';
  static const String buscarUsuario = '$baseUrl/auth/buscar-usuario';
  static const String verificarCodigo = '$baseUrl/auth/verificar-codigo';
  static const String cambiarPasswordExterno =
      '$baseUrl/auth/cambiar-password-externo';
  static const String usuarios = '$baseUrl/auth/usuarios';
  static const String tecnicos = '$baseUrl/orden/tecnicos';
  static const String ordenes = '$baseUrl/orden';
  static const String filtrosValores = '$baseUrl/orden/filtros-valores';
  static const String valoresFormulario = '$baseUrl/orden/valores-formulario';
  static const String retiros = '$baseUrl/retiro';
  static const String retirosExcel = '$baseUrl/retiro/excel';

  static const String excel = '$baseUrl/orden/excel';
  static const String excelCorreo = '$baseUrl/orden/excel-correo';
  static const String excelRespaldo = '$baseUrl/orden/excel-respaldo';
  static const String pdf = '$baseUrl/orden/pdf';
}
