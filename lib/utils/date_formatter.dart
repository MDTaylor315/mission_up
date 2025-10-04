// lib/helpers/date_formatter.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';

// Extensión para la clase String (y nulos)
extension StringDateParsing on String? {
  DateTime? toLocalDateTime() {
    if (this == null) return null;
    try {
      return DateTime.parse(this!).toLocal();
    } catch (e) {
      return null;
    }
  }
}

// Extensión para la clase DateTime
extension DateTimeFormatting on DateTime {
  String toFormattedString(
    BuildContext context, {
    String format = 'd MMM yyyy, h:mm a', // Mantenemos el formato por defecto
  }) {
    final locale = Localizations.localeOf(context)
        .toString(); // Devolverá ej: 'es_PE', 'en_US', 'es_ES'

    return DateFormat(format, locale).format(this);
  }

  static Future<DateTime> getTrueTime({DateTime? fecha}) async {
    try {
      DateTime localDate = fecha ?? DateTime.now();
      // 1. Obtenemos la diferencia (offset) entre la hora del dispositivo y la hora real del servidor NTP.
      // El lookupAddress puede ser cualquier servidor NTP de confianza.
      final int offset = await NTP.getNtpOffset(
          localTime: localDate, lookUpAddress: 'time.google.com');

      // 2. Aplicamos esa diferencia a la hora actual del dispositivo.
      // Si el reloj del usuario está 5 minutos adelantado, el offset será -300,000 milisegundos.
      // Al sumar este offset negativo, corregimos la hora.
      final DateTime realTime = localDate.add(Duration(milliseconds: offset));

      return realTime;
    } catch (e) {
      // Si falla la llamada NTP (ej. sin internet), como fallback, devolvemos la hora del dispositivo.
      // Podrías manejar este error de forma más elegante si lo necesitas.
      print('Error al obtener la hora NTP: $e');
      return fecha ?? DateTime.now();
    }
  }
}

class TimeService extends ChangeNotifier {
  Duration _offset = Duration.zero;
  bool _ready = false;

  Future<void> init() async {
    try {
      // NTP.now() puede retornar DateTime o int según versión; ajusta si es necesario
      final DateTime ntpNow = await NTP.now();
      final DateTime localNow = DateTime.now();
      _offset = ntpNow.difference(localNow);
      _ready = true;
      notifyListeners();
    } catch (e) {
      _offset = Duration.zero;
      _ready = false;
      // opcional: notifyListeners();
    }
  }

  DateTime now() => DateTime.now().add(_offset);

  int todayDay() => now().day;

  bool get isReady => _ready;
}
