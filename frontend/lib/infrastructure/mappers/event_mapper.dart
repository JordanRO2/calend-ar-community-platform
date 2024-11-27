import 'package:frontend/domain/entities/event.dart';
import 'package:frontend/infrastructure/dto/event_dto.dart';

class EventMapper {
  static EventDTO toDto(Event event) {
    return EventDTO(
      id: event.id,
      title: event.title,
      description: event.description,
      community: event.community,
      dateTime: event.dateTime,
      location: event.location,
      createdBy: event.createdBy,
      attendees: event.attendees,
      comments: event.comments,
      likes: event.likes,
      rating: event.rating,
      isRecurring: event.isRecurring,
      recurrencePattern: event.recurrencePattern,
      recurrenceEnd: event.recurrenceEnd,
      featured: event.featured,
      createdAt: event.createdAt,
      reportCount: event.reportCount,
      imageUrl: event.imageUrl,
    );
  }

  static Event fromDto(EventDTO dto) {
    return Event(
      id: dto.id ?? '',
      title: dto.title,
      description: dto.description,
      community: dto.community,
      dateTime: dto.dateTime,
      location: dto.location,
      createdBy: dto.createdBy,
      attendees: dto.attendees,
      comments: dto.comments,
      likes: dto.likes,
      rating: dto.rating,
      isRecurring: dto.isRecurring,
      recurrencePattern: dto.recurrencePattern,
      recurrenceEnd: dto.recurrenceEnd,
      featured: dto.featured,
      createdAt: dto.createdAt ?? DateTime.now(),
      reportCount: dto.reportCount,
      imageUrl: dto.imageUrl,
    );
  }
}
