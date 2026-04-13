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

class Retiro {
  final int? id;
  final DateTime? fechaRetiro;
  final String? serieReversa;
  final String? equipo;

  Retiro({this.id, this.fechaRetiro, this.serieReversa, this.equipo});

  factory Retiro.fromJson(Map<String, dynamic> json) {
    return Retiro(
      id: json['id'],
      fechaRetiro: json['fecha_retiro'] != null
          ? DateTime.tryParse(json['fecha_retiro'])
          : null,
      serieReversa: json['serie_reversa'],
      equipo: json['equipo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fecha_retiro': fechaRetiro?.toIso8601String(),
      'serie_reversa': serieReversa,
      'equipo': equipo,
    };
  }
}

class RetirosResponse {
  final List<Retiro> data;
  final Pagination pagination;

  RetirosResponse({required this.data, required this.pagination});

  factory RetirosResponse.fromJson(Map<String, dynamic> json) {
    return RetirosResponse(
      data:
          (json['data'] as List?)?.map((e) => Retiro.fromJson(e)).toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}
