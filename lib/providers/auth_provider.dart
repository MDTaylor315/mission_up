import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mission_up/models/usuario.dart';
import 'package:mission_up/repositories/auth_repository.dart';

enum AuthStatus { Checking, Authenticated, Unauthenticated }

class AuthService with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  AuthStatus _authStatus = AuthStatus.Checking;
  String? _accessToken;
  Usuario? _currentUser;
  BigInt? _tutorId;

  AuthStatus get authStatus => _authStatus;
  String? get accessToken => _accessToken;
  Usuario? get currentUser => _currentUser;

  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;

  bool get isAuth => _authStatus == AuthStatus.Authenticated;

  AuthService() {
    _checkTokenOnStartup();
  }

  Future<String?> tryRefreshToken() async {
    // Si ya hay un proceso de refresco en curso, esperamos a que termine
    if (_isRefreshing) {
      return _refreshCompleter!.future;
    }

    // Si no, iniciamos uno nuevo
    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();

    final refreshToken = await _storage.read(key: 'refreshToken');
    final sessionId = await _storage.read(key: 'sessionId');

    if (refreshToken == null || sessionId == null) {
      await logout(); // Si no tenemos refresh token, cerramos sesión
      _isRefreshing = false;
      _refreshCompleter!.complete(null);
      return null;
    }

    // Llamamos al repositorio para refrescar el token
    final response = await AuthRepository.refreshToken(
        refreshToken: refreshToken, sessionId: sessionId);

    if (response.isSuccess && response.data != null) {
      // Si el refresco fue exitoso, guardamos el nuevo token
      final newAccessToken = response.data!['access_token'];
      await _saveTokens(
        accessToken: newAccessToken,
        refreshToken: response.data!['refresh_token'] ??
            refreshToken, // Usa el nuevo refresh token si existe
        sessionId: response.data!['session_id'] ?? sessionId,
      );
      print("Token refrescado exitosamente.");
      _isRefreshing = false;
      _refreshCompleter!.complete(newAccessToken);
      return newAccessToken;
    } else {
      // Si el refresco falla (ej. el refresh token también expiró), cerramos sesión
      print("Fallo al refrescar token, cerrando sesión.");
      await logout();
      _isRefreshing = false;
      _refreshCompleter!.complete(null);
      return null;
    }
  }

  Future<void> _checkTokenOnStartup() async {
    await Future.delayed(const Duration(seconds: 3));
    final refreshToken = await _storage.read(key: 'refreshToken');
    final sessionId = await _storage.read(key: 'sessionId');
    String? tutorIdString = await _storage.read(key: 'tutorId');

    if (refreshToken == null || sessionId == null) {
      await logout();
      return;
    }

    final response = await AuthRepository.refreshToken(
        refreshToken: refreshToken,
        sessionId: sessionId,
        tutorId: tutorIdString);

    if (response.isSuccess && response.data != null) {
      _accessToken = response.data!['access_token'];
      _authStatus = AuthStatus.Authenticated;
      _currentUser = Usuario.fromJson(response.data!["user"]);
      if (tutorIdString != null) {
        _tutorId = BigInt.tryParse(tutorIdString);
        print("el tutorID del alumno es $_tutorId");
      }
      print("data usuario ${response.data?['user']}");
    } else {
      await logout();
    }
    notifyListeners();
  }

  // ✅ NUEVO: Este método es llamado por el Controller DESPUÉS de un login exitoso.
  Future<void> handleLoginSuccess(Map<String, dynamic> loginData) async {
    _currentUser = Usuario.fromJson(loginData['user']);
    String? tutorId = loginData['user']['tutor_id'];

    print("el tutorID del alumno es $_tutorId");

    await _saveTokens(
      accessToken: loginData['access_token'],
      refreshToken: loginData['refresh_token'],
      sessionId: loginData['session_id'],
      tutorId: tutorId,
    );
  }

  // Lógica de cierre de sesión (sin cambios)
  Future<void> logout() async {
    // 1. ANTES DE BORRAR NADA, notifica al backend para invalidar la sesión.
    //    Usamos un try-catch para que el logout local funcione incluso sin internet.
    if (_accessToken != null) {
      try {
        final response = await AuthRepository.logout(authService: this);
        // ✅ Verifica si la llamada fue realmente exitosa
        if (response.isSuccess) {
          print("Sesión invalidada exitosamente en el servidor.");
        } else {
          print(
              "El servidor devolvió un error al intentar hacer logout: ${response.error}");
        }
      } catch (e) {
        print("No se pudo notificar al servidor sobre el logout: $e");
      }
    }

    // 2. DESPUÉS, limpia el estado local, PASE LO QUE PASE.
    await _storage.deleteAll();
    _accessToken = null;
    _currentUser = null;
    _tutorId = null;
    _authStatus = AuthStatus.Unauthenticated;

    // 3. Notifica a la UI que el usuario ha cerrado sesión.
    notifyListeners();
  }

  // Método privado para guardar tokens (sin cambios)
  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
    required String sessionId,
    String? tutorId,
  }) async {
    _accessToken = accessToken;
    await _storage.write(key: 'refreshToken', value: refreshToken);

    await _storage.write(key: 'sessionId', value: sessionId);

    if (tutorId != null) {
      await _storage.write(key: 'tutorId', value: tutorId);
      _tutorId = BigInt.parse(tutorId);
      print("el tutorID del alumno es $_tutorId");
    }
    _authStatus = AuthStatus.Authenticated;
    if (!_isRefreshing) {
      notifyListeners();
    }
  }
}
