import 'package:flutter/material.dart';
import 'package:mission_up/models/alumno.dart';
import 'package:mission_up/providers/auth_provider.dart';
import 'package:mission_up/repositories/alumno_repository.dart';

class AlumnoProvider with ChangeNotifier {
  AuthService? authService;
  AlumnoProvider(this.authService);

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /////////////////////////////////////////////////////////////
  List<Alumno> _solicitudesPendientes = [];
  List<Alumno> _alumnosActivos = [];

  // Getters que la UI usará
  List<Alumno> get solicitudesPendientes => _solicitudesPendientes;
  List<Alumno> get alumnosActivos => _alumnosActivos;

  bool _isLoadingSolicitudes = false;
  bool _isLoadingActivos = false;
  bool get isLoadingSolicitudes => _isLoadingSolicitudes;
  bool get isLoadingActivos => _isLoadingActivos;
  /////////////////////////////////////////////////////////////
  void updateAuth(AuthService auth) {
    authService = auth;
    // recarga datos solo si hace falta
    // fetchAlumnos();
  }

  // TODO: Esta función se conectará a tu backend
  Future<void> fetchSolicitudes() async {
    _isLoadingSolicitudes = true;
    notifyListeners();

    // Llama a tu repositorio, que a su vez llama a GET /alumnos/solicitudes
    final response =
        await AlumnoRepository.getSolicitudes(authService: authService!);
    if (response.isSuccess) {
      _solicitudesPendientes = response.data ?? [];
    }

    _isLoadingSolicitudes = false;
    notifyListeners();
  }

  Future<void> fetchAlumnosActivos({String? fecha}) async {
    if (!authService!.isAuth) {
      return;
    }
    _isLoadingActivos = true;
    notifyListeners();
    print("fecha $fecha");
    // Llama a GET /alumnos/activos-con-asignaciones?fecha=...
    final response = await AlumnoRepository.getAlumnosActivos(
      authService: authService!,
      fecha: fecha,
    );
    print("Alumnos activos cargados: ${response.data}");

    if (response.isSuccess) {
      _alumnosActivos = response.data ?? [];
    }

    _isLoadingActivos = false;
    notifyListeners();
  }

  Future<void> aceptarSolicitud(Alumno solicitud) async {
    if (!authService!.isAuth) {
      return;
    }
    final indexOriginal = _solicitudesPendientes.indexOf(solicitud);

    // Actualización optimista: quitamos la solicitud de la UI al instante
    _solicitudesPendientes.removeWhere((s) => s.id == solicitud.id);
    notifyListeners();

    try {
      final response = await AlumnoRepository.acceptAlumno(
        authService: authService!,
        alumnoId: solicitud.id,
      );
      if (response.isSuccess && response.data != null) {
        final alumnoRecienAceptado = response.data!;
        print("Alumno aceptado: $alumnoRecienAceptado");
        _alumnosActivos.insert(0, Alumno.fromJson(alumnoRecienAceptado));
      } else {
        throw Exception(response.error);
      }
    } catch (e, stacktrace) {
      print("Error al aceptar solicitud: $e $stacktrace");
      if (indexOriginal != -1) {
        _solicitudesPendientes.insert(indexOriginal, solicitud);
      }
      _error = "No se pudo aceptar la solicitud.";
    } finally {
      notifyListeners();
    }
  }

  Future<void> rechazarSolicitud(Alumno solicitud) async {
    if (!authService!.isAuth) return;
    final indexOriginal = _solicitudesPendientes.indexOf(solicitud);
    if (indexOriginal == -1) return;

    _solicitudesPendientes.removeAt(indexOriginal);
    notifyListeners();

    try {
      final response = await AlumnoRepository.rejectAlumno(
        authService: authService!,
        alumnoId: solicitud.id,
      );
      if (!response.isSuccess) throw Exception(response.error);
    } catch (e) {
      _solicitudesPendientes.insert(indexOriginal, solicitud);
      _error = "No se pudo rechazar la solicitud.";
      notifyListeners();
    }
  }
}
