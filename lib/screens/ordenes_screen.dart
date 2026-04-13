import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/orden.dart';
import '../services/api_service.dart';
import 'formulario_orden_screen.dart';

class OrdenesScreen extends StatefulWidget {
  const OrdenesScreen({super.key});

  @override
  State<OrdenesScreen> createState() => _OrdenesScreenState();
}

class _OrdenesScreenState extends State<OrdenesScreen> {
  final OrdenService _ordenService = OrdenService();

  List<Orden> _ordenes = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;

  String? _osFilter;
  String? _tecnicoFilter;
  String? _estadoFilter;
  String? _equipoFilter;
  String? _marcaFilter;
  String? _clienteFilter;
  String? _fechaAsignacionDesde;
  String? _fechaAsignacionHasta;
  String? _fechaReparacionDesde;
  String? _fechaReparacionHasta;

  List<String> _tecnicos = [];
  List<String> _equipos = [];
  List<String> _marcas = [];
  List<String> _clientes = [];
  List<String> _estados = [
    'Reparado en bodega',
    'Equipo irreparable en bodega',
  ];

  @override
  void initState() {
    super.initState();
    _loadTecnicos();
    _loadFiltrosValores();
    _loadOrdenes();
  }

  Future<void> _loadTecnicos() async {
    final result = await _ordenService.getTecnicos();
    if (result['success'] && mounted) {
      setState(() {
        _tecnicos = (result['data'] as List)
            .map((e) => e['usuario'].toString())
            .toList();
      });
    }
  }

  Future<void> _loadFiltrosValores() async {
    final result = await _ordenService.getFiltrosValores();
    if (result['success'] && mounted) {
      final data = result['data'];
      setState(() {
        _equipos = (data['equipos'] as List?)?.cast<String>() ?? [];
        _marcas = (data['marcas'] as List?)?.cast<String>() ?? [];
        _clientes = (data['clientes'] as List?)?.cast<String>() ?? [];
      });
    }
  }

  Future<void> _loadOrdenes() async {
    setState(() => _isLoading = true);

    final result = await _ordenService.getOrdenes(
      page: _currentPage,
      os: _osFilter,
      tecnico: _tecnicoFilter,
      estado: _estadoFilter,
      equipo: _equipoFilter,
      marca: _marcaFilter,
      cliente: _clienteFilter,
      fechaAsignacionDesde: _fechaAsignacionDesde,
      fechaAsignacionHasta: _fechaAsignacionHasta,
      fechaReparacionDesde: _fechaReparacionDesde,
      fechaReparacionHasta: _fechaReparacionHasta,
    );

    if (result['success'] && mounted) {
      final response = OrdenesResponse.fromJson(result['data']);
      setState(() {
        _ordenes = response.data;
        _totalPages = response.pagination.totalPages;
        _total = response.pagination.total;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['msg'] ?? 'Error al cargar órdenes')),
      );
    }

    setState(() => _isLoading = false);
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16).copyWith(bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Filtros de Informes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'OS',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        onChanged: (v) => setModalState(() => _osFilter = v),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _clienteFilter,
                        decoration: const InputDecoration(
                          labelText: 'Cliente',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ..._clientes.map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() => _clienteFilter = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _tecnicoFilter,
                        decoration: const InputDecoration(
                          labelText: 'Técnico',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ..._tecnicos.map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() => _tecnicoFilter = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _estadoFilter,
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ..._estados.map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() => _estadoFilter = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _equipoFilter,
                        decoration: const InputDecoration(
                          labelText: 'Equipo',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ..._equipos.map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() => _equipoFilter = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _marcaFilter,
                        decoration: const InputDecoration(
                          labelText: 'Marca',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ..._marcas.map(
                            (m) => DropdownMenuItem(value: m, child: Text(m)),
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() => _marcaFilter = value);
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Fechas de Asignación',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              'Desde',
                              _fechaAsignacionDesde,
                              (d) => setModalState(
                                () => _fechaAsignacionDesde = d,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDateField(
                              'Hasta',
                              _fechaAsignacionHasta,
                              (d) => setModalState(
                                () => _fechaAsignacionHasta = d,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Fechas de Reparación',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              'Desde',
                              _fechaReparacionDesde,
                              (d) => setModalState(
                                () => _fechaReparacionDesde = d,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDateField(
                              'Hasta',
                              _fechaReparacionHasta,
                              (d) => setModalState(
                                () => _fechaReparacionHasta = d,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  _osFilter = null;
                                  _clienteFilter = null;
                                  _tecnicoFilter = null;
                                  _estadoFilter = null;
                                  _equipoFilter = null;
                                  _marcaFilter = null;
                                  _fechaAsignacionDesde = null;
                                  _fechaAsignacionHasta = null;
                                  _fechaReparacionDesde = null;
                                  _fechaReparacionHasta = null;
                                });
                              },
                              child: const Text('Limpiar'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _currentPage = 1;
                                });
                                _loadOrdenes();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF009EE3),
                              ),
                              child: const Text('Aplicar'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDateField(
    String label,
    String? value,
    Function(String?) onChanged,
  ) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      controller: TextEditingController(text: value),
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value != null
              ? DateTime.tryParse(value) ?? DateTime.now()
              : DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          cancelText: 'Cancelar',
          confirmText: 'Aceptar',
          locale: const Locale('es', 'CL'),
        );
        if (date != null) {
          onChanged(date.toIso8601String().split('T')[0]);
        }
      },
    );
  }

  Future<void> _eliminarOrden(Orden orden) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar orden ${orden.os}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && orden.id != null) {
      final result = await _ordenService.eliminarOrden(orden.id!);
      if (result['success'] && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Orden eliminada')));
        _loadOrdenes();
      }
    }
  }

  void _showExportMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Excel Carga'),
                onTap: () {
                  Navigator.pop(context);
                  _exportarExcel('excel');
                },
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Excel Correo'),
                onTap: () {
                  Navigator.pop(context);
                  _exportarExcel('excel-correo');
                },
              ),
              ListTile(
                leading: const Icon(Icons.save),
                title: const Text('Excel Respaldo'),
                onTap: () {
                  Navigator.pop(context);
                  _exportarExcel('excel-respaldo');
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Exportar PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _exportarPdf();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportarExcel(String tipo) async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Descargando...')));

      final filters = <String, String>{};
      if (_osFilter != null && _osFilter!.isNotEmpty)
        filters['os'] = _osFilter!;
      if (_clienteFilter != null && _clienteFilter!.isNotEmpty)
        filters['cliente'] = _clienteFilter!;
      if (_tecnicoFilter != null && _tecnicoFilter!.isNotEmpty)
        filters['tecnico'] = _tecnicoFilter!;
      if (_estadoFilter != null && _estadoFilter!.isNotEmpty)
        filters['estado'] = _estadoFilter!;
      if (_equipoFilter != null && _equipoFilter!.isNotEmpty)
        filters['equipo'] = _equipoFilter!;
      if (_marcaFilter != null && _marcaFilter!.isNotEmpty)
        filters['marca'] = _marcaFilter!;
      if (_fechaAsignacionDesde != null)
        filters['fechaAsignacionDesde'] = _fechaAsignacionDesde!;
      if (_fechaAsignacionHasta != null)
        filters['fechaAsignacionHasta'] = _fechaAsignacionHasta!;
      if (_fechaReparacionDesde != null)
        filters['fechaReparacionDesde'] = _fechaReparacionDesde!;
      if (_fechaReparacionHasta != null)
        filters['fechaReparacionHasta'] = _fechaReparacionHasta!;

      Uint8List bytes;
      String filename;

      if (tipo == 'excel-correo') {
        bytes = await _ordenService.descargarExcelCorreo(filters: filters);
        filename = 'informe_correo.xlsx';
      } else if (tipo == 'excel-respaldo') {
        bytes = await _ordenService.descargarExcelRespaldo(filters: filters);
        filename = 'respaldo.xlsx';
      } else {
        bytes = await _ordenService.descargarExcel(filters: filters);
        filename = 'informe_carga.xlsx';
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename');
      await file.writeAsBytes(bytes);

      if (!mounted) return;

      await Share.shareXFiles([XFile(file.path)], text: 'Exportar $filename');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Descargado: $filename')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _exportarPdf() async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Descargando PDF...')));

      final filters = <String, String>{};
      if (_osFilter != null && _osFilter!.isNotEmpty)
        filters['os'] = _osFilter!;
      if (_clienteFilter != null && _clienteFilter!.isNotEmpty)
        filters['cliente'] = _clienteFilter!;
      if (_tecnicoFilter != null && _tecnicoFilter!.isNotEmpty)
        filters['tecnico'] = _tecnicoFilter!;
      if (_estadoFilter != null && _estadoFilter!.isNotEmpty)
        filters['estado'] = _estadoFilter!;
      if (_equipoFilter != null && _equipoFilter!.isNotEmpty)
        filters['equipo'] = _equipoFilter!;
      if (_marcaFilter != null && _marcaFilter!.isNotEmpty)
        filters['marca'] = _marcaFilter!;
      if (_fechaAsignacionDesde != null)
        filters['fechaAsignacionDesde'] = _fechaAsignacionDesde!;
      if (_fechaAsignacionHasta != null)
        filters['fechaAsignacionHasta'] = _fechaAsignacionHasta!;
      if (_fechaReparacionDesde != null)
        filters['fechaReparacionDesde'] = _fechaReparacionDesde!;
      if (_fechaReparacionHasta != null)
        filters['fechaReparacionHasta'] = _fechaReparacionHasta!;

      final bytes = await _ordenService.descargarPdf(filters: filters);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/informes.pdf');
      await file.writeAsBytes(bytes);

      if (!mounted) return;

      await Share.shareXFiles([XFile(file.path)], text: 'Exportar PDF');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF descargado: informes.pdf')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informes'),
        backgroundColor: const Color(0xFF0C4A8C),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormularioOrdenScreen()),
          ).then((_) => _loadOrdenes());
        },
        backgroundColor: const Color(0xFF009EE3),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: $_total registros',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: _showExportMenu,
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('Exportar'),
                          ),
                          TextButton.icon(
                            onPressed: _showFilterDialog,
                            icon: const Icon(Icons.filter_list, size: 18),
                            label: const Text('Filtros'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _ordenes.isEmpty
                      ? const Center(child: Text('No hay órdenes'))
                      : ListView.builder(
                          itemCount: _ordenes.length,
                          itemBuilder: (context, index) {
                            final orden = _ordenes[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: ListTile(
                                title: Text(
                                  orden.os ?? 'Sin OS',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Cliente: ${orden.cliente ?? "-"}'),
                                    Text('Técnico: ${orden.tecnico ?? "-"}'),
                                    Text(
                                      'Equipo: ${orden.equipo ?? "-"} ${orden.marca ?? ""}',
                                    ),
                                    Text(
                                      'Estado: ${orden.estadoActual ?? "-"}',
                                    ),
                                    Text('Fecha: ${_formatDate(orden.fecha)}'),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: 8),
                                          Text('Editar'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Eliminar',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FormularioOrdenScreen(
                                            orden: orden,
                                          ),
                                        ),
                                      ).then((_) => _loadOrdenes());
                                    } else if (value == 'delete') {
                                      _eliminarOrden(orden);
                                    }
                                  },
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                ),
                if (_totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _currentPage > 1
                              ? () {
                                  setState(() => _currentPage--);
                                  _loadOrdenes();
                                }
                              : null,
                        ),
                        Text('Página $_currentPage de $_totalPages'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _currentPage < _totalPages
                              ? () {
                                  setState(() => _currentPage++);
                                  _loadOrdenes();
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
