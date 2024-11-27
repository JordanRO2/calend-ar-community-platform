// relative path: frontend/lib/application/use_cases/calendars/get_calendar_subscribers_use_case.dart

import 'package:frontend/domain/interfaces/calendar_repository.dart';

class GetCalendarSubscribersUseCase {
  final CalendarRepository calendarRepository;

  GetCalendarSubscribersUseCase(this.calendarRepository);

  /// Obtiene la lista de suscriptores de un calendario llamando al método correspondiente en el repositorio.
  Future<List<String>> execute(String calendarId) async {
    try {
      return await calendarRepository.getSubscribers(calendarId);
    } catch (e) {
      print('Error al obtener los suscriptores del calendario: $e');
      return [];
    }
  }
}
