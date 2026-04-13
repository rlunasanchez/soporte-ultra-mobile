import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoggedIn = false;
  String _usuario = '';
  String _rol = '';
  bool _isLoading = false;

  DateTime? _lastActivity;

  static const Duration _timeoutDuration = Duration(minutes: 10);

  bool get isLoggedIn => _isLoggedIn;
  String get usuario => _usuario;
  String get rol => _rol;
  bool get isLoading => _isLoading;

  void resetActivityTimer() {
    _lastActivity = DateTime.now();
  }

  void _checkInactivity() {
    if (_isLoggedIn && _lastActivity != null) {
      final now = DateTime.now();
      if (now.difference(_lastActivity!) > _timeoutDuration) {
        logout();
      }
    }
  }

  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    _isLoggedIn = await _authService.isLoggedIn();
    if (_isLoggedIn) {
      _usuario = await _authService.getUsuario() ?? '';
      _rol = await _authService.getRol() ?? 'tecnico';
      resetActivityTimer();
      _startInactivityCheck();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _startInactivityCheck() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 10));
      if (_isLoggedIn) {
        _checkInactivity();
        return true;
      }
      return false;
    });
  }

  Future<Map<String, dynamic>> login(String usuario, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(usuario, password);

    if (result['success']) {
      _isLoggedIn = true;
      _usuario = result['usuario'];
      _rol = result['rol'] ?? 'tecnico';
      resetActivityTimer();
      _startInactivityCheck();
    }

    _isLoading = false;
    notifyListeners();

    return result;
  }

  Future<void> logout() async {
    await _authService.logout();
    _isLoggedIn = false;
    _usuario = '';
    _rol = '';
    _lastActivity = null;
    notifyListeners();
  }
}
