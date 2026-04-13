class Orden {
  final int? id;
  final String? os;
  final String? cliente;
  final String? tecnico;
  final DateTime? asignacion;
  final String? enGarantia;
  final String? tipo;
  final String? estadoActual;
  final DateTime? fechaReparacion;
  final String? solicitudCompra;
  final String? nDenuncia;
  final String? qty;
  final String? anexo;
  final DateTime? fecha;
  final String? equipo;
  final String? marca;
  final String? serie;
  final String? modelo;
  final String? procesador;
  final String? disco;
  final String? memoria;
  final bool cargador;
  final bool bateria;
  final bool insumo;
  final bool cabezal;
  final String? otros;
  final String? fallaInformada;
  final String? fallaDetectada;
  final String? conclusion;
  final String? realizadoPor;
  final DateTime? fechaDiagnostico;
  final String? diagnostico;

  Orden({
    this.id,
    this.os,
    this.cliente,
    this.tecnico,
    this.asignacion,
    this.enGarantia,
    this.tipo,
    this.estadoActual,
    this.fechaReparacion,
    this.solicitudCompra,
    this.nDenuncia,
    this.qty,
    this.anexo,
    this.fecha,
    this.equipo,
    this.marca,
    this.serie,
    this.modelo,
    this.procesador,
    this.disco,
    this.memoria,
    this.cargador = false,
    this.bateria = false,
    this.insumo = false,
    this.cabezal = false,
    this.otros,
    this.fallaInformada,
    this.fallaDetectada,
    this.conclusion,
    this.realizadoPor,
    this.fechaDiagnostico,
    this.diagnostico,
  });

  factory Orden.fromJson(Map<String, dynamic> json) {
    return Orden(
      id: json['id'],
      os: json['os'],
      cliente: json['cliente'],
      tecnico: json['tecnico'],
      asignacion: json['asignacion'] != null
          ? DateTime.tryParse(json['asignacion'])
          : null,
      enGarantia: json['en_garantia'],
      tipo: json['tipo'],
      estadoActual: json['estado_actual'],
      fechaReparacion: json['fecha_reparacion'] != null
          ? DateTime.tryParse(json['fecha_reparacion'])
          : null,
      solicitudCompra: json['solicitud_compra'],
      nDenuncia: json['n_denuncia'],
      qty: json['qty'],
      anexo: json['anexo'],
      fecha: json['fecha'] != null ? DateTime.tryParse(json['fecha']) : null,
      equipo: json['equipo'],
      marca: json['marca'],
      serie: json['serie'],
      modelo: json['modelo'],
      procesador: json['procesador'],
      disco: json['disco'],
      memoria: json['memoria'],
      cargador: json['cargador'] ?? false,
      bateria: json['bateria'] ?? false,
      insumo: json['insumo'] ?? false,
      cabezal: json['cabezal'] ?? false,
      otros: json['otros'],
      fallaInformada: json['falla_informada'],
      fallaDetectada: json['falla_detectada'],
      conclusion: json['conclusion'],
      realizadoPor: json['realizado_por'],
      fechaDiagnostico: json['fecha_diagnostico'] != null
          ? DateTime.tryParse(json['fecha_diagnostico'])
          : null,
      diagnostico: json['diagnostico'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'os': os,
      'cliente': cliente,
      'tecnico': tecnico,
      'asignacion': asignacion?.toIso8601String(),
      'en_garantia': enGarantia,
      'tipo': tipo,
      'estado_actual': estadoActual,
      'fecha_reparacion': fechaReparacion?.toIso8601String(),
      'solicitud_compra': solicitudCompra,
      'n_denuncia': nDenuncia,
      'qty': qty,
      'anexo': anexo,
      'fecha': fecha?.toIso8601String(),
      'equipo': equipo,
      'marca': marca,
      'serie': serie,
      'modelo': modelo,
      'procesador': procesador,
      'disco': disco,
      'memoria': memoria,
      'cargador': cargador,
      'bateria': bateria,
      'insumo': insumo,
      'cabezal': cabezal,
      'otros': otros,
      'falla_informada': fallaInformada,
      'falla_detectada': fallaDetectada,
      'conclusion': conclusion,
      'realizado_por': realizadoPor,
      'fecha_diagnostico': fechaDiagnostico?.toIso8601String(),
      'diagnostico': diagnostico,
    };
  }
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: int.tryParse(json['page']?.toString() ?? '1') ?? 1,
      limit: int.tryParse(json['limit']?.toString() ?? '5') ?? 5,
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      totalPages: int.tryParse(json['totalPages']?.toString() ?? '0') ?? 0,
    );
  }
}

class OrdenesResponse {
  final List<Orden> data;
  final Pagination pagination;

  OrdenesResponse({required this.data, required this.pagination});

  factory OrdenesResponse.fromJson(Map<String, dynamic> json) {
    return OrdenesResponse(
      data:
          (json['data'] as List?)?.map((e) => Orden.fromJson(e)).toList() ?? [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}
