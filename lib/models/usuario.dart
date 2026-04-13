class Usuario {
  final int id;
  final String usuario;
  final String rol;
  final bool activo;
  final String? email;
  final DateTime? fechaCreacion;

  Usuario({
    required this.id,
    required this.usuario,
    required this.rol,
    required this.activo,
    this.email,
    this.fechaCreacion,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      usuario: json['usuario'] ?? '',
      rol: json['rol'] ?? 'tecnico',
      activo: json['activo'] ?? true,
      email: json['email'],
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario': usuario,
      'rol': rol,
      'activo': activo,
      'email': email,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
    };
  }
}
