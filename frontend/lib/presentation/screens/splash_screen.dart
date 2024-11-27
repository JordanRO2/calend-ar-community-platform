import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/providers/user_provider.dart';
import 'package:frontend/presentation/widgets/common/common_logo.dart';
import 'package:frontend/presentation/widgets/splash/splash_loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndRedirect();
  }

  Future<void> _checkAuthenticationAndRedirect() async {
    final userProvider = context.read<UserProvider>();

    // Simula un tiempo de espera en la pantalla de splash
    await Future.delayed(const Duration(seconds: 2));

    // Verifica si el usuario está autenticado
    final isAuthenticated = await userProvider.checkAuthentication();

    // Dentro de _checkAuthenticationAndRedirect en el SplashScreen
    if (isAuthenticated) {
      context.replace('/home'); // Reemplaza la ruta actual (SplashScreen)
    } else {
      context.replace('/login'); // Reemplaza la ruta actual (SplashScreen)
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CommonLogo(height: 150), // Logo de la aplicación
            SizedBox(height: 20),
            SplashLoadingIndicator(), // Indicador de carga
          ],
        ),
      ),
    );
  }
}
