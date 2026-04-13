import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/orden.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class FormularioOrdenScreen extends StatefulWidget {
  final Orden? orden;

  const FormularioOrdenScreen({super.key, this.orden});

  @override
  State<FormularioOrdenScreen> createState() => _FormularioOrdenScreenState();
}

class _FormularioOrdenScreenState extends State<FormularioOrdenScreen> {
  final _formKey = GlobalKey<FormState>();
  final OrdenService _ordenService = OrdenService();

  final _osController = TextEditingController();
  final _clienteController = TextEditingController();
  final _solicitudCompraController = TextEditingController();
  final _nDenunciaController = TextEditingController();
  final _qtyController = TextEditingController();
  final _anexoController = TextEditingController();
  final _equipoController = TextEditingController();
  final _marcaController = TextEditingController();
  final _serieController = TextEditingController();
  final _modeloController = TextEditingController();
  final _procesadorController = TextEditingController();
  final _discoController = TextEditingController();
  final _memoriaController = TextEditingController();
  final _otrosController = TextEditingController();
  final _fallaInformadaController = TextEditingController();
  final _fallaDetectadaController = TextEditingController();
  final _conclusionController = TextEditingController();
  final _realizadoPorController = TextEditingController();

  String? _tecnico;
  String? _enGarantia;
  String? _tipo;
  String? _estadoActual;
  String _cliente = 'Banco Estado';

  DateTime? _asignacion;
  DateTime? _fechaReparacion;
  DateTime? _fecha;
  DateTime? _fechaDiagnostico;
  String _diagnostico = '';

  List<String> _equipos = [];
  List<String> _marcas = [];
  List<String> _modelos = [];

  bool _cargador = false;
  bool _bateria = false;
  bool _insumo = false;
  bool _cabezal = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadValoresFormulario();
    if (widget.orden != null) {
      _cargarOrden(widget.orden!);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final auth = context.read<AuthProvider>();
        setState(() {
          _tecnico = auth.usuario;
          _enGarantia = 'NO';
          _tipo = 'Reparación';
          _estadoActual = 'Reparado en bodega';
        });
      });
    }
  }

  Future<void> _loadValoresFormulario() async {
    final result = await _ordenService.getValoresFormulario();
    if (result['success'] && mounted) {
      setState(() {
        _equipos = (result['data']['equipos'] as List?)?.cast<String>() ?? [];
        _marcas = (result['data']['marcas'] as List?)?.cast<String>() ?? [];
        _modelos = (result['data']['modelos'] as List?)?.cast<String>() ?? [];
      });
    }
  }

  void _cargarOrden(Orden orden) {
    _osController.text = orden.os ?? '';
    _clienteController.text = orden.cliente ?? 'Banco Estado';
    _solicitudCompraController.text = orden.solicitudCompra ?? '';
    _nDenunciaController.text = orden.nDenuncia ?? '';
    _qtyController.text = orden.qty ?? '';
    _anexoController.text = orden.anexo ?? '';
    _equipoController.text = orden.equipo ?? '';
    _marcaController.text = orden.marca ?? '';
    _serieController.text = orden.serie ?? '';
    _modeloController.text = orden.modelo ?? '';
    _procesadorController.text = orden.procesador ?? '';
    _discoController.text = orden.disco ?? '';
    _memoriaController.text = orden.memoria ?? '';
    _otrosController.text = orden.otros ?? '';
    _fallaInformadaController.text = orden.fallaInformada ?? '';
    _fallaDetectadaController.text = orden.fallaDetectada ?? '';
    _conclusionController.text = orden.conclusion ?? '';
    _realizadoPorController.text = orden.realizadoPor ?? '';

    _tecnico = orden.tecnico;
    _enGarantia = orden.enGarantia;
    _tipo = orden.tipo;
    _estadoActual = orden.estadoActual;
    _asignacion = orden.asignacion;
    _fechaReparacion = orden.fechaReparacion;
    _fecha = orden.fecha;
    _cargador = orden.cargador;
    _bateria = orden.bateria;
    _insumo = orden.insumo;
    _cabezal = orden.cabezal;
    _fechaDiagnostico = orden.fechaDiagnostico;
    _diagnostico = orden.diagnostico ?? '';
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final ordenData = {
      'os': _osController.text,
      'cliente': _clienteController.text,
      'tecnico': _tecnico,
      'asignacion': _asignacion?.toIso8601String(),
      'en_garantia': _enGarantia,
      'tipo': _tipo,
      'estado_actual': _estadoActual,
      'fecha_reparacion': _fechaReparacion?.toIso8601String(),
      'solicitud_compra': _solicitudCompraController.text,
      'n_denuncia': _nDenunciaController.text,
      'qty': _qtyController.text,
      'anexo': _anexoController.text,
      'fecha': _fecha?.toIso8601String(),
      'equipo': _equipoController.text,
      'marca': _marcaController.text,
      'serie': _serieController.text,
      'modelo': _modeloController.text,
      'procesador': _procesadorController.text,
      'disco': _discoController.text,
      'memoria': _memoriaController.text,
      'cargador': _cargador,
      'bateria': _bateria,
      'insumo': _insumo,
      'cabezal': _cabezal,
      'otros': _otrosController.text,
      'falla_informada': _fallaInformadaController.text,
      'falla_detectada': _fallaDetectadaController.text,
      'conclusion': _conclusionController.text,
      'realizado_por': _realizadoPorController.text,
      'fecha_diagnostico': _fechaDiagnostico?.toIso8601String(),
      'diagnostico': _diagnostico,
    };

    Map<String, dynamic> result;
    if (widget.orden != null) {
      result = await _ordenService.actualizarOrden(
        widget.orden!.id!,
        ordenData,
      );
    } else {
      result = await _ordenService.crearOrden(ordenData);
    }

    setState(() => _isLoading = false);

    if (result['success'] && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.orden != null ? 'Orden actualizada' : 'Orden creada',
          ),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['msg'] ?? 'Error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _osController.dispose();
    _clienteController.dispose();
    _solicitudCompraController.dispose();
    _nDenunciaController.dispose();
    _qtyController.dispose();
    _anexoController.dispose();
    _equipoController.dispose();
    _marcaController.dispose();
    _serieController.dispose();
    _modeloController.dispose();
    _procesadorController.dispose();
    _discoController.dispose();
    _memoriaController.dispose();
    _otrosController.dispose();
    _fallaInformadaController.dispose();
    _fallaDetectadaController.dispose();
    _conclusionController.dispose();
    _realizadoPorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.orden != null ? 'Editar Informe' : 'Nuevo Informe Técnico',
        ),
        backgroundColor: const Color(0xFF0C4A8C),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16).copyWith(bottom: 100),
                children: [
                  _buildSectionTitle('Datos Principales'),
                  TextFormField(
                    controller: _osController,
                    decoration: const InputDecoration(
                      labelText: 'OS *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _clienteController,
                    decoration: const InputDecoration(
                      labelText: 'Cliente',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: _tecnico,
                    decoration: const InputDecoration(
                      labelText: 'Técnico',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false,
                    onChanged: (v) => setState(() => _tecnico = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _enGarantia,
                    decoration: const InputDecoration(
                      labelText: 'En Garantía',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'SI', child: Text('SI')),
                      DropdownMenuItem(value: 'NO', child: Text('NO')),
                    ],
                    onChanged: (v) => setState(() => _enGarantia = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _tipo,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Reparación',
                        child: Text('Reparación'),
                      ),
                      DropdownMenuItem(
                        value: 'Mantención',
                        child: Text('Mantención'),
                      ),
                      DropdownMenuItem(value: 'DOA', child: Text('DOA')),
                    ],
                    onChanged: (v) => setState(() => _tipo = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _estadoActual,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Reparado en bodega',
                        child: Text('Reparado en bodega'),
                      ),
                      DropdownMenuItem(
                        value: 'Equipo irreparable en bodega',
                        child: Text('Equipo irreparable en bodega'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _estadoActual = v),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Fechas'),
                  _buildDateField(
                    'Asignación',
                    _asignacion,
                    (d) => setState(() => _asignacion = d),
                  ),
                  _buildDateField(
                    'Fecha Reparación',
                    _fechaReparacion,
                    (d) => setState(() => _fechaReparacion = d),
                  ),
                  _buildDateField(
                    'Fecha',
                    _fecha,
                    (d) => setState(() => _fecha = d),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Datos del Equipo'),
                  DropdownButtonFormField<String>(
                    value: _equipos.contains(_equipoController.text)
                        ? _equipoController.text
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Equipo',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Seleccionar equipo'),
                      ),
                      ..._equipos.map(
                        (e) => DropdownMenuItem(value: e, child: Text(e)),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _equipoController.text = v ?? ''),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _marcas.contains(_marcaController.text)
                        ? _marcaController.text
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Marca',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Seleccionar marca'),
                      ),
                      ..._marcas.map(
                        (m) => DropdownMenuItem(value: m, child: Text(m)),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _marcaController.text = v ?? ''),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _serieController,
                    decoration: const InputDecoration(
                      labelText: 'Serie',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _modelos.contains(_modeloController.text)
                        ? _modeloController.text
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Modelo',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Seleccionar modelo'),
                      ),
                      ..._modelos.map(
                        (m) => DropdownMenuItem(value: m, child: Text(m)),
                      ),
                    ],
                    onChanged: (v) =>
                        setState(() => _modeloController.text = v ?? ''),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _procesadorController,
                    decoration: const InputDecoration(
                      labelText: 'Procesador',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _discoController,
                    decoration: const InputDecoration(
                      labelText: 'Disco',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _memoriaController,
                    decoration: const InputDecoration(
                      labelText: 'Memoria',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Accesorios'),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Cargador'),
                        selected: _cargador,
                        onSelected: (v) => setState(() => _cargador = v),
                      ),
                      FilterChip(
                        label: const Text('Batería'),
                        selected: _bateria,
                        onSelected: (v) => setState(() => _bateria = v),
                      ),
                      FilterChip(
                        label: const Text('Insumo'),
                        selected: _insumo,
                        onSelected: (v) => setState(() => _insumo = v),
                      ),
                      FilterChip(
                        label: const Text('Cabezal'),
                        selected: _cabezal,
                        onSelected: (v) => setState(() => _cabezal = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _otrosController,
                    decoration: const InputDecoration(
                      labelText: 'Otros',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Información Técnica'),
                  TextFormField(
                    controller: _solicitudCompraController,
                    decoration: const InputDecoration(
                      labelText: 'Solicitud Compra',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nDenunciaController,
                    decoration: const InputDecoration(
                      labelText: 'N° Denuncia',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _qtyController,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _anexoController,
                    decoration: const InputDecoration(
                      labelText: 'Anexo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Fallas y Conclusión'),
                  TextFormField(
                    controller: _fallaInformadaController,
                    decoration: const InputDecoration(
                      labelText: 'Falla Informada',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _fallaDetectadaController,
                    decoration: const InputDecoration(
                      labelText: 'Falla Detectada',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _conclusionController,
                    decoration: const InputDecoration(
                      labelText: 'Conclusión',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _realizadoPorController,
                    decoration: const InputDecoration(
                      labelText: 'Realizado Por',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Diagnóstico'),
                  _buildDateField(
                    'Fecha Diagnóstico',
                    _fechaDiagnostico,
                    (d) => setState(() => _fechaDiagnostico = d),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: _diagnostico,
                    decoration: const InputDecoration(
                      labelText: 'Diagnóstico',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    onChanged: (v) => _diagnostico = v,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009EE3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(widget.orden != null ? 'ACTUALIZAR' : 'CREAR'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0C4A8C),
        ),
      ),
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? value,
    Function(DateTime?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        subtitle: Text(
          value != null
              ? DateFormat('dd/MM/yyyy').format(value)
              : 'No selected',
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          onChanged(date);
        },
      ),
    );
  }
}
