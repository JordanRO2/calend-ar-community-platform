// relative path: frontend/lib/application/use_cases/calendars/create_calendar_use_case.dart

import 'package:frontend/domain/entities/calendar.dart';
import 'package:frontend/domain/interfaces/calendar_repository.dart';

class CreateCalendarUseCase {
  final CalendarRepository calendarRepository;

  CreateCalendarUseCase(this.calendarRepository);

  /// Crea un nuevo calendario llamando al método correspondiente en el repositorio.
  Future<String?> execute(Calendar calendar) async {
    try {
      return await calendarRepository.createCalendar(calendar);
    } catch (e) {
      print('Error al crear el calendario: $e');
      return null;
    }
  }
}
