import 'package:flutter/material.dart';
import 'package:mission_up/models/actividad.dart';
import 'package:mission_up/models/actividad_grupo.dart';
import 'package:mission_up/models/tipo_actividad.dart';
import 'package:mission_up/providers/auth_provider.dart';
import 'package:mission_up/repositories/actividad_repository.dart';

class ActividadesProvider with ChangeNotifier {
  final AuthService authService;
  ActividadesProvider(this.authService);
  // --- 1. EL NUEVO ESTADO ---
  // Ahora solo tenemos una lista de grupos como fuente de la verdad.
  List<ActividadGrupo> _grupos = [];
  bool _isLoading = true;
  int? _selectedTipoId;
  String _searchQuery = '';
  String? _error;

// --- 2. GETTERS INTELIGENTES ---
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get selectedTipoId => _selectedTipoId;

  // ✅ GETTER CORREGIDO
  // Devuelve una lista del modelo más simple: TipoActividad
  List<TipoActividad> get tipos {
    // Mapeamos sobre la lista de grupos completa...
    return _grupos
        .map((grupo) =>
            // ...y para cada grupo, creamos un objeto 'TipoActividad' simple.
            // Esto es más eficiente y le da a la UI exactamente lo que necesita.
            TipoActividad(
              id: grupo.tipoId,
              descripcion: grupo.tipoDescripcion,
              detalle: grupo.tipoDetalle,
            ))
        .toList();
  }

  // ✅ GETTER DE ACTIVIDADES (Esto está perfecto)
  List<Actividad> get actividadesMostradas {
    if (_selectedTipoId == null) return [];

    final grupoSeleccionado = _grupos.firstWhere(
      (grupo) => grupo.tipoId == _selectedTipoId,
      orElse: () =>
          ActividadGrupo(tipoId: 0, tipoDescripcion: '', actividades: []),
    );

    List<Actividad> result = grupoSeleccionado.actividades;

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((act) =>
              act.titulo.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return result;
  }

  List<ActividadGrupo> get gruposMostrados {
    if (_searchQuery.isEmpty) {
      return _grupos; // Si no hay búsqueda, devuelve todos los grupos
    }

    // Si hay búsqueda, filtramos las actividades DENTRO de cada grupo
    return _grupos.map((grupo) {
      final actividadesFiltradas = grupo.actividades
          .where((act) =>
              act.titulo.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

      // Creamos un nuevo objeto de grupo con solo las actividades filtradas
      return ActividadGrupo(
        tipoId: grupo.tipoId,
        tipoDescripcion: grupo.tipoDescripcion,
        actividades: actividadesFiltradas,
      );
    }).toList();
  }

  // --- 3. EL MÉTODO PARA CARGAR DATOS ---
  // Recibe el AuthService para poder usar el token de acceso
  Future<void> fetchActividades() async {
    _isLoading = true;
    notifyListeners();

    final token = authService.accessToken;
    if (token == null) {
      _error = "Usuario no autenticado.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    final response = await ActividadRepository.getActividadesAgrupadas(
        authService: authService);

    if (response.isSuccess && response.data != null) {
      _grupos = response.data!;
      _error = null;
    } else {
      _error = response.error;
    }

    print("response ${response.data}");

    _isLoading = false;
    notifyListeners();
  }

  // --- 4. ACCIONES DE LA UI (casi sin cambios) ---
  void selectTipo(int tipoId) {
    _selectedTipoId = tipoId;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
