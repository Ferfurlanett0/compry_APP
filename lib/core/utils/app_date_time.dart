import 'package:intl/intl.dart';

/// Centraliza a apresentação de horários vindos do Firestore.
///
/// Timestamps são persistidos pelo servidor e convertidos apenas na borda de UI
/// para o fuso configurado no aparelho. Isso evita aplicar UTC-3 duas vezes e
/// deslocar uma lista para o dia anterior/seguinte.
abstract final class AppDateTime {
  static DateTime local(DateTime value) => value.toLocal();

  static String full(DateTime value) =>
      DateFormat("dd/MM/yyyy 'às' HH:mm", 'pt_BR').format(local(value));

  static String compact(DateTime value) =>
      DateFormat("dd/MM 'às' HH:mm", 'pt_BR').format(local(value));

  static String time(DateTime value) =>
      DateFormat('HH:mm', 'pt_BR').format(local(value));

  static String relative(DateTime value, {DateTime? now}) {
    final localValue = local(value);
    final localNow = (now ?? DateTime.now()).toLocal();
    final date = DateTime(localValue.year, localValue.month, localValue.day);
    final today = DateTime(localNow.year, localNow.month, localNow.day);
    final difference = today.difference(date).inDays;

    if (difference == 0) return 'Hoje às ${time(localValue)}';
    if (difference == 1) return 'Ontem às ${time(localValue)}';
    return compact(localValue);
  }

  static bool isSameLocalDay(DateTime a, DateTime b) {
    final first = local(a);
    final second = local(b);
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
