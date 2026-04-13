import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/retiro.dart';
import '../services/api_service.dart';

class RetirosScreen extends StatefulWidget {
  const RetirosScreen({super.key});

  @override
  State<RetirosScreen> createState() => _RetirosScreenState();
}

class _RetirosScreenState extends State<RetirosScreen> {
  final RetiroService _retiroService = RetiroService();

  List<Retiro> _retiros = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;

  String? _fechaDesde;
  String? _fechaHasta;

  @override
  void initState() {
    super.initState();
    _loadRetiros();
  }

  Future<void> _loadRetiros() async {
    setState(() => _isLoading = true);

    final result = await _retiroService.getRetiros(
      page: _currentPage,
      limit: 10,
      fechaDesde: _fechaDesde,
      fechaHasta: _fechaHasta,
    );

    if (result['success'] && mounted) {
      final response = RetirosResponse.fromJson(result['data']);
      setState(() {
        _retiros = response.data;
        _totalPages = response.pagination.totalPages;
        _total = response.pagination.total;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['msg'] ?? 'Error al cargar retiros')),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _eliminarRetiro(Retiro retiro) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Eliminar este retiro?'),
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

    if (confirm == true && retiro.id != null) {
      final result = await _retiroService.eliminarRetiro(retiro.id!);
      if (result['success'] && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Retiro eliminado')));
        _loadRetiros();
      }
    }
  }

  void _showEditarRetiroDialog(Retiro retiro) {
    final serieController = TextEditingController(text: retiro.serieReversa);
    final equipoController = TextEditingController(text: retiro.equipo);
    DateTime fechaRetiro = retiro.fechaRetiro ?? DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Retiro'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Fecha de Retiro'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(fechaRetiro)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: fechaRetiro,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      cancelText: 'Cancelar',
                      confirmText: 'Aceptar',
                      locale: const Locale('es', 'CL'),
                    );
                    if (date != null) {
                      setDialogState(() => fechaRetiro = date);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: serieController,
                  decoration: const InputDecoration(
                    labelText: 'Serie Reversa',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: equipoController,
                  decoration: const InputDecoration(
                    labelText: 'Equipo',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (serieController.text.isEmpty ||
                    equipoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todos los campos son obligatorios'),
                    ),
                  );
                  return;
                }
                final result = await _retiroService.actualizarRetiro(
                  retiro.id!,
                  {
                    'fecha_retiro': fechaRetiro.toIso8601String().split('T')[0],
                    'serie_reversa': serieController.text,
                    'equipo': equipoController.text,
                  },
                );
                if (result['success'] && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Retiro actualizado')),
                  );
                  _loadRetiros();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['msg'] ?? 'Error')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009EE3),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 40,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtrar Retiros',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Desde',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(text: _fechaDesde),
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _fechaDesde != null
                                  ? DateTime.tryParse(_fechaDesde!) ??
                                        DateTime.now()
                                  : DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setModalState(() {
                                _fechaDesde = date.toIso8601String().split(
                                  'T',
                                )[0];
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Hasta',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(text: _fechaHasta),
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _fechaHasta != null
                                  ? DateTime.tryParse(_fechaHasta!) ??
                                        DateTime.now()
                                  : DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setModalState(() {
                                _fechaHasta = date.toIso8601String().split(
                                  'T',
                                )[0];
                              });
                            }
                          },
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
                              _fechaDesde = null;
                              _fechaHasta = null;
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
                            _loadRetiros();
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
  }

  void _showCrearRetiroDialog() {
    final serieController = TextEditingController();
    final equipoController = TextEditingController();
    DateTime fechaRetiro = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nuevo Retiro'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Fecha de Retiro'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(fechaRetiro)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: fechaRetiro,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      cancelText: 'Cancelar',
                      confirmText: 'Aceptar',
                      locale: const Locale('es', 'CL'),
                    );
                    if (date != null) {
                      setDialogState(() => fechaRetiro = date);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: serieController,
                  decoration: const InputDecoration(
                    labelText: 'Serie Reversa',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: equipoController,
                  decoration: const InputDecoration(
                    labelText: 'Equipo',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (serieController.text.isEmpty ||
                    equipoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Todos los campos son obligatorios'),
                    ),
                  );
                  return;
                }
                final result = await _retiroService.crearRetiro({
                  'fecha_retiro': fechaRetiro.toIso8601String().split('T')[0],
                  'serie_reversa': serieController.text,
                  'equipo': equipoController.text,
                });
                if (result['success'] && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Retiro creado')),
                  );
                  _loadRetiros();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['msg'] ?? 'Error')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009EE3),
              ),
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportarExcel() async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Descargando...')));

      final bytes = await _retiroService.descargarExcel(
        fechaDesde: _fechaDesde,
        fechaHasta: _fechaHasta,
      );

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/retiros_bodega.xlsx');
      await file.writeAsBytes(bytes);

      if (!mounted) return;

      await Share.shareXFiles([XFile(file.path)], text: 'Exportar retiros');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descargado: retiros_bodega.xlsx')),
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
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retiros de Bodega'),
        backgroundColor: const Color(0xFF0C4A8C),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCrearRetiroDialog,
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
                        'Total: $_total retiros',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: _exportarExcel,
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
                  child: _retiros.isEmpty
                      ? const Center(child: Text('No hay retiros'))
                      : ListView.builder(
                          itemCount: _retiros.length,
                          itemBuilder: (context, index) {
                            final retiro = _retiros[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFE8F5E9),
                                  child: Icon(
                                    Icons.inventory_2,
                                    color: Colors.green,
                                  ),
                                ),
                                title: Text(
                                  retiro.equipo ?? 'Sin equipo',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Serie: ${retiro.serieReversa ?? "-"}',
                                    ),
                                    Text(
                                      'Fecha: ${_formatDate(retiro.fechaRetiro)}',
                                    ),
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
                                      _showEditarRetiroDialog(retiro);
                                    } else if (value == 'delete') {
                                      _eliminarRetiro(retiro);
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
                                  _loadRetiros();
                                }
                              : null,
                        ),
                        Text('Página $_currentPage de $_totalPages'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _currentPage < _totalPages
                              ? () {
                                  setState(() => _currentPage++);
                                  _loadRetiros();
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
