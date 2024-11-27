// relative path: frontend/lib/infrastructure/mappers/calendar_mapper.dart

import 'package:frontend/domain/entities/calendar.dart';
import 'package:frontend/domain/entities/event.dart';
import 'package:frontend/infrastructure/dto/calendar_dto.dart';

class CalendarMapper {
  /// Convierte un objeto `Calendar` en un `CalendarDTO`.
  static CalendarDTO toDto(Calendar calendar) {
    return CalendarDTO(
      id: calendar.id,
      name: calendar.name,
      owner: calendar.owner,
      events: calendar.events.map((event) => event.toString()).toList(),
      isPublic: calendar.isPublic,
      sharedUrl: calendar.sharedUrl,
      createdAt: calendar.createdAt,
    );
  }

  /// Convierte un objeto `CalendarDTO` en un objeto `Calendar`.
  static Calendar fromDto(CalendarDTO dto) {
    return Calendar(
      id: dto.id ?? '',
      name: dto.name,
      owner: dto.owner,
      events: dto.events.map((event) => Event.fromString(event)).toList(),
      isPublic: dto.isPublic,
      sharedUrl: dto.sharedUrl ?? '',
      createdAt: dto.createdAt ?? DateTime.now(),
    );
  }
}
