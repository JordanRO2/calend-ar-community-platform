// frontend/lib/presentation/widgets/home_screen/web_home_layout.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/home_screen/home_tabs.dart';

class WebHomeLayout extends StatefulWidget {
  const WebHomeLayout({super.key});

  @override
  State<WebHomeLayout> createState() => _WebHomeLayoutState();
}

class _WebHomeLayoutState extends State<WebHomeLayout> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const CalendarTab(),
    const CommunitiesTab(),
    const EventsTab(),
    const ProfileTab(),
    const NotificationsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSideNavigationBar(),
          Expanded(
            child: _tabs[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavigationBar() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        setState(() => _selectedIndex = index);
      },
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home),
          label: Text('Inicio'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.calendar_today),
          label: Text('Calendario'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.group),
          label: Text('Comunidades'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.event),
          label: Text('Eventos'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person),
          label: Text('Perfil'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.notifications),
          label: Text('Notificaciones'),
        ),
      ],
    );
  }
}
