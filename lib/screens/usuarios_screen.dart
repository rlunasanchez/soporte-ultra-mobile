import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/orden.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class UsuariosScreen extends StatefulWidget {
  const UsuariosScreen({super.key});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final UsuarioService _usuarioService = UsuarioService();
  List<Usuario> _usuarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsuarios();
  }

  Future<void> _loadUsuarios() async {
    setState(() => _isLoading = true);
    final result = await _usuarioService.getUsuarios();
    if (result['success'] && mounted) {
      setState(() {
        _usuarios = (result['data'] as List)
            .map((e) => Usuario.fromJson(e))
            .toList();
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _activarUsuario(Usuario usuario) async {
    final result = await _usuarioService.activarUsuario(
      usuario.id,
      !usuario.activo,
    );
    if (result['success'] && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            usuario.activo ? 'Usuario desactivado' : 'Usuario activado',
          ),
        ),
      );
      _loadUsuarios();
    }
  }

  Future<void> _eliminarUsuario(Usuario usuario) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Eliminar usuario ${usuario.usuario}?'),
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

    if (confirm == true) {
      final result = await _usuarioService.eliminarUsuario(usuario.id);
      if (result['success'] && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Usuario eliminado')));
        _loadUsuarios();
      }
    }
  }

  void _showCrearUsuarioDialog() {
    final usuarioController = TextEditingController();
    final passwordController = TextEditingController();
    final emailController = TextEditingController();
    String rol = 'tecnico';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Crear Usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usuarioController,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: rol,
                  decoration: const InputDecoration(
                    labelText: 'Rol',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'tecnico', child: Text('Técnico')),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => rol = value ?? 'tecnico'),
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
                if (usuarioController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuario y password son obligatorios'),
                    ),
                  );
                  return;
                }
                final result = await _usuarioService.crearUsuario({
                  'usuario': usuarioController.text,
                  'password': passwordController.text,
                  'rol': rol,
                  'email': emailController.text,
                });
                if (result['success'] && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario creado')),
                  );
                  _loadUsuarios();
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.rol == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: const Color(0xFF0C4A8C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadUsuarios),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _showCrearUsuarioDialog,
              backgroundColor: const Color(0xFF009EE3),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _usuarios.isEmpty
          ? const Center(child: Text('No hay usuarios'))
          : ListView.builder(
              itemCount: _usuarios.length,
              itemBuilder: (context, index) {
                final usuario = _usuarios[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: usuario.rol == 'admin'
                          ? Colors.red[100]
                          : Colors.blue[100],
                      child: Icon(
                        usuario.rol == 'admin'
                            ? Icons.admin_panel_settings
                            : Icons.person,
                        color: usuario.rol == 'admin'
                            ? Colors.red
                            : Colors.blue,
                      ),
                    ),
                    title: Text(
                      usuario.usuario,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rol: ${usuario.rol}'),
                        Text('Email: ${usuario.email ?? "-"}'),
                        Text(
                          'Estado: ${usuario.activo ? "Activo" : "Inactivo"}',
                        ),
                      ],
                    ),
                    trailing: isAdmin
                        ? PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'toggle',
                                child: Row(
                                  children: [
                                    Icon(
                                      usuario.activo
                                          ? Icons.block
                                          : Icons.check_circle,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      usuario.activo ? 'Desactivar' : 'Activar',
                                    ),
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
                              if (value == 'toggle') {
                                _activarUsuario(usuario);
                              } else if (value == 'delete') {
                                _eliminarUsuario(usuario);
                              }
                            },
                          )
                        : null,
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
