import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mission_up/app_theme.dart';
import 'package:mission_up/widgets/task_row.dart';
import 'package:mission_up/widgets/tasks_card.dart';
import 'package:mission_up/widgets/widgets.dart';

class HomeDashboardScreen extends StatefulWidget {
  final bool isAdmin; // 👈 Nuevo parámetro

  const HomeDashboardScreen({super.key, this.isAdmin = false});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  // Colores aproximados del mock
  static const kTextDim = Colors.white70;

  // Estado para el calendario
  String selectedMonth = 'Junio';
  int selectedDay = 1;

  // Función para obtener el número de días en un mes
  int getDaysInMonth(String month, int year) {
    const monthDays = {
      'Enero': 31,
      'Febrero': 28,
      'Marzo': 31,
      'Abril': 30,
      'Mayo': 31,
      'Junio': 30,
      'Julio': 31,
      'Agosto': 31,
      'Septiembre': 30,
      'Octubre': 31,
      'Noviembre': 30,
      'Diciembre': 31,
    };

    int days = monthDays[month] ?? 31;

    // Lógica para años bisiestos en febrero
    if (month == 'Febrero' && isLeapYear(year)) {
      days = 29;
    }

    return days;
  }

  // Función para verificar si es año bisiesto
  bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  // Función para obtener el nombre del día de la semana
  String getDayName(int day, String month) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    int currentYear = DateTime.now().year;
    int monthIndex = [
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
        ].indexOf(month) +
        1;

    DateTime date = DateTime(currentYear, monthIndex, day);
    return days[date.weekday - 1];
  }

  // Generar lista de días para el mes seleccionado
  List<Widget> generateDayPills() {
    int currentYear = DateTime.now().year;
    int daysInMonth = getDaysInMonth(selectedMonth, currentYear);

    return List.generate(daysInMonth, (index) {
      int day = index + 1;
      String dayName = getDayName(day, selectedMonth);

      return _DatePill(
        day: dayName,
        date: day.toString().padLeft(2, '0'),
        active: selectedDay == day,
        onTap: () {
          setState(() {
            selectedDay = day;
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    print("isAdmin ${widget.isAdmin}");
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
                      'Bienvenido, David',
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
              if (widget.isAdmin)
                Column(
                  children: [
                    // Código de familia
                    _FamilyCodeCard(code: '021932'),
                    const SizedBox(height: 8),

                    // Mes (INTEGRADO CON CALENDARIO)
                    _MonthPickerCard(
                      value: selectedMonth,
                      onChanged: (String? newMonth) {
                        if (newMonth != null) {
                          setState(() {
                            selectedMonth = newMonth;
                            // Resetear el día seleccionado si es mayor al máximo del nuevo mes
                            int maxDays =
                                getDaysInMonth(newMonth, DateTime.now().year);
                            if (selectedDay > maxDays) {
                              selectedDay = 1;
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Hijos
                    TaskCard(
                      name: 'Marlon',
                      subtitle: '1/3 tareas realizadas',
                      coins: 1,
                    ),
                    const SizedBox(height: 10),
                    TaskCard(
                      name: 'Paolo',
                      subtitle: '0/3 tareas realizadas',
                      coins: 0,
                    ),
                    const SizedBox(height: 10),
                    TaskCard.request(
                      name: 'Saul',
                      subtitle: 'Solicitud de unión',
                      onAccept: () {},
                      onReject: () {},
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
    const months = [
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
