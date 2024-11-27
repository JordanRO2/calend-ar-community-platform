import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/presentation/screens/splash_screen.dart';
import 'package:frontend/presentation/screens/login_screen.dart';
import 'package:frontend/presentation/screens/register_screen.dart';
import 'package:frontend/presentation/screens/forgot_password_screen.dart';
import 'package:frontend/presentation/screens/home_screen.dart';

// Importaciones de pantallas de eventos
// import 'package:frontend/presentation/screens/events/event_details_screen.dart';
// import 'package:frontend/presentation/screens/events/create_event_screen.dart';
// import 'package:frontend/presentation/screens/events/edit_event_screen.dart';

// Importaciones de pantallas de comunidades
// import 'package:frontend/presentation/screens/communities/community_details_screen.dart';
// import 'package:frontend/presentation/screens/communities/create_community_screen.dart';
// import 'package:frontend/presentation/screens/communities/edit_community_screen.dart';

// Importaciones de pantallas de calendario
// import 'package:frontend/presentation/screens/calendars/calendar_details_screen.dart';
// import 'package:frontend/presentation/screens/calendars/create_calendar_screen.dart';
// import 'package:frontend/presentation/screens/calendars/edit_calendar_screen.dart';

// Importaciones de pantallas de perfil
// import 'package:frontend/presentation/screens/profile/edit_profile_screen.dart';
// import 'package:frontend/presentation/screens/profile/change_password_screen.dart';
import 'package:frontend/presentation/widgets/home_screen/tabs/settings_tab.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      routes: [
        // Rutas de autenticación
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),

        // Ruta principal
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),

        // Rutas de eventos
        // GoRoute(
        //   path: '/events/:id',
        //   builder: (context, state) => EventDetailsScreen(
        //     eventId: state.pathParameters['id']!,
        //   ),
        // ),
        // GoRoute(
        //   path: '/events/create',
        //   builder: (context, state) => const CreateEventScreen(),
        // ),
        // GoRoute(
        //   path: '/events/:id/edit',
        //   builder: (context, state) => EditEventScreen(
        //     eventId: state.pathParameters['id']!,
        //   ),
        // ),

        // // Rutas de comunidades
        // GoRoute(
        //   path: '/communities/:id',
        //   builder: (context, state) => CommunityDetailsScreen(
        //     communityId: state.pathParameters['id']!,
        //   ),
        // ),
        // GoRoute(
        //   path: '/communities/create',
        //   builder: (context, state) => const CreateCommunityScreen(),
        // ),
        // GoRoute(
        //   path: '/communities/:id/edit',
        //   builder: (context, state) => EditCommunityScreen(
        //     communityId: state.pathParameters['id']!,
        //   ),
        // ),

        // // Rutas de calendario
        // GoRoute(
        //   path: '/calendars/:id',
        //   builder: (context, state) => CalendarDetailsScreen(
        //     calendarId: state.pathParameters['id']!,
        //   ),
        // ),
        // GoRoute(
        //   path: '/calendars/create',
        //   builder: (context, state) => const CreateCalendarScreen(),
        // ),
        // GoRoute(
        //   path: '/calendars/:id/edit',
        //   builder: (context, state) => EditCalendarScreen(
        //     calendarId: state.pathParameters['id']!,
        //   ),
        // ),

        // // Rutas de perfil y configuración
        // GoRoute(
        //   path: '/profile/edit',
        //   builder: (context, state) => const EditProfileScreen(),
        // ),
        // GoRoute(
        //   path: '/profile/password',
        //   builder: (context, state) => const ChangePasswordScreen(),
        // ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsTab(),
        ),
      ],
      errorBuilder: (context, state) => const Scaffold(
        body: Center(
          child: Text('Página no encontrada'),
        ),
      ),
    );
  }
}
