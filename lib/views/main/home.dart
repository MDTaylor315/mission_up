import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/controllers/home_controller.dart';
import 'package:mission_up/providers/alumno_provider.dart';
import 'package:mission_up/providers/auth_provider.dart';
import 'package:mission_up/utils/date_formatter.dart';
import 'package:mission_up/widgets/task_row.dart';
import 'package:mission_up/widgets/tasks_card.dart';
import 'package:mission_up/widgets/widgets.dart';
import 'package:provider/provider.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  // Colores aproximados del mock
  static const kTextDim = Colors.white70;
  final controller = HomeController();
  // Estado para el calendario
  String selectedMonth = 'Junio';
  int selectedDay = 1;
  DateTime _fechaSeleccionada = DateTime.now();

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timeService = context.read<TimeService>();

      // ✅ 2. Actualizamos nuestra única variable de estado de fecha.
      //    Esto es importante si tu TimeService está configurado para pruebas.
      _fechaSeleccionada = timeService.now();
      _onDateSelected(_fechaSeleccionada, isInitialLoad: true);

      setState(() {
        selectedMonth = _monthNameFromInt(timeService.now().month);
        _onDateSelected(_fechaSeleccionada, isInitialLoad: true);
      });
    });
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _onDateSelected(DateTime nuevaFecha, {bool isInitialLoad = false}) {
    if (!isInitialLoad) {
      setState(() {
        _fechaSeleccionada = nuevaFecha;
        print("Fecha seleccionada: $nuevaFecha");
      });
    }

    final provider = context.read<AlumnoProvider>();
    final authService = context.read<AuthService>();
    final fechaFormateada = DateFormat('yyyy-MM-dd').format(nuevaFecha);

    provider.fetchAlumnosActivos(fecha: fechaFormateada);
  }

  // Función para obtener el número de días en un mes
  int getDaysInMonth(int month, int year) {
    int diasMes = 0;
    if (month != DateTime.now().month) {
      diasMes = DateTime(year, month + 1, 0).day;
    } else {
      diasMes = DateTime.now().day;
    }
    return diasMes;
  }

  String _monthNameFromInt(int month) {
    const names = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return names[month - 1];
  }

  // Función para verificar si es año bisiesto
  bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  // Función para obtener el nombre del día de la semana
  String getDayName(int day, int month, int year) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final date = DateTime(year, month, day);
    return days[date.weekday - 1];
  }

  // Generar lista de días para el mes seleccionado
  List<Widget> generateDayPills() {
    final int year = _fechaSeleccionada.year;
    final int month = _fechaSeleccionada.month;
    final int daysInMonth = getDaysInMonth(month, year);

    return List.generate(daysInMonth, (index) {
      int day = index + 1;
      String dayName = getDayName(day, month, year);

      return _DatePill(
        day: dayName,
        date: day.toString().padLeft(2, '0'),
        active: _fechaSeleccionada.day == day,
        onTap: () {
          final nuevaFecha = DateTime(year, month, day);
          _onDateSelected(nuevaFecha); // <-- Llama al cerebro
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final alumnoProvider = context.watch<AlumnoProvider>();
    final isAdmin = authService.currentUser?.isAdmin ?? false;
    final bool esHoy = _isToday(_fechaSeleccionada);

    print("isAdmin ${isAdmin}");
    return Scaffold(
      extendBody: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Bienvenido, ${authService.currentUser?.nombre}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 24),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none,
                        color: Colors.white70),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isAdmin)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Código de familia
                    _FamilyCodeCard(
                        code: "${authService.currentUser?.codigoInvitacion}"),
                    const SizedBox(height: 8),

                    // Mes (INTEGRADO CON CALENDARIO)
                    _MonthPickerCard(
                      // El valor del dropdown ahora se deriva de _fechaSeleccionada
                      value: _monthNameFromInt(_fechaSeleccionada.month),
                      onChanged: (String? newMonthName) {
                        if (newMonthName != null) {
                          final int newMonthIndex = [
                                'Enero',
                                'Febrero',
                                'Marzo',
                                'Abril',
                                'Mayo',
                                'Junio',
                                'Julio',
                                'Agosto',
                                'Septiembre',
                                'Octubre',
                                'Noviembre',
                                'Diciembre'
                              ].indexOf(newMonthName) +
                              1;
                          print("si cambia");
                          // Creamos una nueva fecha y llamamos a nuestra función central
                          final nuevaFecha = DateTime(
                              _fechaSeleccionada.year, newMonthIndex, 1);
                          _onDateSelected(nuevaFecha);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    if (alumnoProvider.isLoadingActivos)
                      const Center(child: CircularProgressIndicator())
                    else if (alumnoProvider.alumnosActivos.isEmpty)
                      const Text('No hay alumnos activos para mostrar.',
                          style: TextStyle(color: Colors.white70))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: alumnoProvider.alumnosActivos.length,
                        itemBuilder: (context, index) {
                          final alumno = alumnoProvider.alumnosActivos[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: TaskCard(
                              // Tu widget para alumnos activos
                              name: alumno.nombre,
                              subtitle: alumno.resumenTareas,
                              coins: alumno.puntosHoy,
                              // onTap: () => ... (lógica para seleccionar al alumno)
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 15),
                    if (alumnoProvider.solicitudesPendientes.isNotEmpty)
                      Text(
                        'Solicitudes pendientes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 22),
                      ),
                    const SizedBox(height: 10),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: alumnoProvider.solicitudesPendientes.length,
                      itemBuilder: (context, index) {
                        final solicitud =
                            alumnoProvider.solicitudesPendientes[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: TaskCard.request(
                              name: solicitud.nombre,
                              subtitle: 'Solicitud de unión',
                              onAccept: () =>
                                  controller.acceptAlumno(context, solicitud),
                              onReject: () =>
                                  controller.rejectAlumno(context, solicitud)),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              // Total de puntos
              RichText(
                text: TextSpan(
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white),
                  children: const [
                    TextSpan(
                      text: 'Total de Puntos : ',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    TextSpan(
                        text: '120  ',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 18)),
                    TextSpan(
                        text: '(175 + 70 - 5)',
                        style: TextStyle(color: kTextDim)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Stats (ganados / canjeados / penalizados)
              Row(
                children: const [
                  Expanded(
                      child: _StatTile(label: 'Puntos Ganados', value: '175')),
                  SizedBox(width: 10),
                  Expanded(
                      child: _StatTile(label: 'Puntos Canjeados', value: '70')),
                  SizedBox(width: 10),
                  Expanded(
                      child:
                          _StatTile(label: 'Puntos Penalizados', value: '5')),
                ],
              ),
              const SizedBox(height: 16),

              // CALENDARIO DINÁMICO (reemplaza la lista estática)
              SizedBox(
                height: 55,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: generateDayPills(),
                ),
              ),
              const SizedBox(height: 14),

              // Tareas
              const TaskRow(label: 'Hacer la cama', coins: 2, checked: false),
              const SizedBox(height: 10),
              const TaskRow(
                  label: 'Participar en clase', coins: 3, checked: false),
              const SizedBox(height: 10),
              const TaskRow(
                  label: 'Limpiar el cuarto', coins: 1, checked: true),
            ],
          ),
        ),
      ),

      // Bottom bar
    );
  }
}

// === Widgets auxiliares ===

class _FamilyCodeCard extends StatelessWidget {
  final String code;
  const _FamilyCodeCard({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.blackLight,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Código de Familia : $code',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Clipboard.setData(ClipboardData(text: code)),
            icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

class _MonthPickerCard extends StatelessWidget {
  static const kCardSoft = Color(0xFF2B2F33);

  final String value;
  final ValueChanged<String?> onChanged;

  const _MonthPickerCard({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    List<String> months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];

    print("dia actual ${DateTime.now().day}");
    months = months.sublist(0, DateTime.now().month);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.blackLight,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white70,
          ),
          dropdownColor: kCardSoft,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          items: months
              .map((m) => DropdownMenuItem(
                    value: m,
                    child: Text('Mes : $m'),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.blackLight,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      constraints: const BoxConstraints(minHeight: 82),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _HomeDashboardScreenState.kTextDim,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          monedas(int.parse(value), alignment: MainAxisAlignment.center),
        ],
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final String day;
  final String date;
  final bool active;
  final VoidCallback? onTap;

  const _DatePill({
    required this.day,
    required this.date,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: active ? AppTheme.grey : AppTheme.blackLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppTheme.grey : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
