// frontend/lib/presentation/widgets/home_screen/tabs/calendar_tab.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:frontend/presentation/widgets/common/common_empty_state_message.dart';
import 'package:frontend/presentation/widgets/common/common_section_title.dart';
import 'package:frontend/presentation/widgets/common/common_responsive_breakpoints.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/domain/entities/event.dart';
import 'package:frontend/domain/entities/calendar.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _loadCalendarData();
  }

  // Carga de datos simulados
  void _loadCalendarData() {
    // Simulación de datos de calendarios y eventos
    final mockCalendars = [
      Calendar(
        id: 'cal1',
        name: 'Trabajo',
        owner: 'Owner1',
        sharedUrl: 'http://example.com/cal1',
        createdAt: DateTime.now(),
        events: [
          Event(
            id: 'e1',
            title: 'Reunión de Proyecto',
            dateTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
            location: 'Sala de Conferencias 1',
            description: 'Descripción de la reunión de proyecto',
            community: 'Trabajo',
            createdBy: 'Owner1',
            createdAt: DateTime.now(),
          ),
          Event(
            id: 'e2',
            title: 'Presentación de Ventas',
            dateTime: DateTime.now().add(const Duration(days: 3, hours: 14)),
            location: 'Sala de Reuniones 2',
            description: 'Descripción de la presentación de ventas',
            community: 'Trabajo',
            createdBy: 'Owner1',
            createdAt: DateTime.now(),
          ),
          Event(
            id: 'e3',
            title: 'Cena con Amigos',
            dateTime: DateTime.now().add(const Duration(days: 2, hours: 19)),
            location: 'Restaurante La Buena Mesa',
            description: 'Descripción de la cena con amigos',
            community: 'Personal',
            createdBy: 'Owner2',
            createdAt: DateTime.now(),
          ),
          Event(
            id: 'e4',
            title: 'Clase de Yoga',
            dateTime: DateTime.now().add(const Duration(days: 4, hours: 8)),
            location: 'Centro de Yoga Zen',
            description: 'Descripción de la clase de yoga',
            community: 'Personal',
            createdBy: 'Owner2',
            createdAt: DateTime.now(),
          ),
        ],
      ),
    ];

    // Procesar eventos después de la fase de construcción para evitar llamadas a setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _processEvents(mockCalendars);
      }
    });
  }

  // Procesamiento de eventos para el calendario
  void _processEvents(List<Calendar> calendars) {
    setState(() {
      _events.clear();
      for (var calendar in calendars) {
        for (var event in calendar.events) {
          final eventDate = DateTime(
            event.dateTime.year,
            event.dateTime.month,
            event.dateTime.day,
          );
          if (_events.containsKey(eventDate)) {
            _events[eventDate]!.add(event);
          } else {
            _events[eventDate] = [event];
          }
        }
      }
    });
  }

  // Obtiene eventos para un día específico
  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final isWeb =
        context.isWeb; // Usando la extensión de CommonResponsiveBreakpoints

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.calendarTitle),
        actions: [
          if (isWeb)
            TextButton.icon(
              onPressed: () => context.push('/calendars/create'),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                AppTexts.myCalendarSectionTitle,
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >
              CommonResponsiveBreakpoints.mobileMaxWidth) {
            // Diseño para pantallas grandes (web)
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _CalendarContent(
                    focusedDay: _focusedDay,
                    selectedDay: _selectedDay,
                    calendarFormat: _calendarFormat,
                    events: _events,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    getEventsForDay: _getEventsForDay,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _EventsList(
                    selectedDay: _selectedDay ?? _focusedDay,
                    events: _getEventsForDay(_selectedDay ?? _focusedDay),
                  ),
                ),
              ],
            );
          } else {
            // Diseño para pantallas pequeñas (móviles)
            return _CalendarContent(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              calendarFormat: _calendarFormat,
              events: _events,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              getEventsForDay: _getEventsForDay,
            );
          }
        },
      ),
      floatingActionButton: isWeb
          ? null
          : FloatingActionButton(
              onPressed: () => context.push('/calendars/create'),
              child: const Icon(Icons.add),
            ),
    );
  }
}

class _CalendarContent extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat calendarFormat;
  final Map<DateTime, List<Event>> events;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;
  final List<Event> Function(DateTime) getEventsForDay;

  const _CalendarContent({
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.events,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.getEventsForDay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Event>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDay,
          calendarFormat: calendarFormat,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          eventLoader: getEventsForDay,
          onDaySelected: onDaySelected,
          onFormatChanged: onFormatChanged,
          // Personalización del calendario
          calendarStyle: CalendarStyle(
            markersMaxCount: 3,
            markerDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            todayDecoration: const BoxDecoration(
              color: Colors.orangeAccent,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
          ),
          // Encabezados personalizados
          headerStyle: HeaderStyle(
            formatButtonShowsNext: false,
            titleCentered: true,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary, // Usar color del tema
            ),
            titleTextStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary, // Texto adaptado al fondo
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            formatButtonTextStyle:
                TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            formatButtonDecoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .secondary, // Usar color del tema
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Mostrar eventos solo en pantallas pequeñas
        if (context.isMobile)
          Expanded(
            child: _EventsList(
              selectedDay: selectedDay ?? focusedDay,
              events: getEventsForDay(selectedDay ?? focusedDay),
            ),
          ),
      ],
    );
  }
}

class _EventsList extends StatelessWidget {
  final DateTime selectedDay;
  final List<Event> events;

  const _EventsList({
    required this.selectedDay,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const CommonEmptyStateMessage(
        message: 'No hay eventos para este día.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: CommonSectionTitle(
            title: '${AppTexts.date}: ${_formatDate(selectedDay)}',
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _EventCard(event: event);
            },
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _EventCard extends StatelessWidget {
  final Event event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          event.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _EventInfo(
              icon: Icons.access_time,
              text: _formatTime(event.dateTime),
            ),
            const SizedBox(height: 4),
            _EventInfo(
              icon: Icons.location_on,
              text: event.location,
            ),
          ],
        ),
        onTap: () => context.push('/events/${event.id}'),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _EventInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EventInfo({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }
}
