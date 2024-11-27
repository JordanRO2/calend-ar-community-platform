// frontend/lib/presentation/widgets/login_screen/login_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/widgets/login_screen/login_form_fields.dart';
import 'package:frontend/presentation/widgets/login_screen/login_actions.dart';
import 'package:frontend/presentation/providers/user_provider.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:frontend/presentation/widgets/common/common_snackbar.dart';
import 'package:go_router/go_router.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    final userProvider = context.read<UserProvider>();
    if (userProvider.isAuthenticated) {
      if (mounted) context.go('/home');
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    context.showErrorSnackBar(message);
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    context.showSuccessSnackBar(message);
  }

  void _showLoadingOverlay(bool show) {
    setState(() => _isSubmitting = show);
  }

  Future<void> _handleLogin() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      _showErrorMessage(AppTexts.loginFormError);
      return;
    }

    _showLoadingOverlay(true);

    try {
      final userProvider = context.read<UserProvider>();

      await userProvider.loginUser(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        if (userProvider.isAuthenticated) {
          _showSuccessMessage(AppTexts.loginSuccess);
          // Pequeño delay para que el usuario pueda ver el mensaje de éxito
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            context.go('/home');
          }
        } else {
          _showErrorMessage(AppTexts.loginError);
        }
      }
    } catch (e) {
      _showErrorMessage(e.toString());
    } finally {
      if (mounted) {
        _showLoadingOverlay(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              LoginFormFields(
                emailController: _emailController,
                passwordController: _passwordController,
                isPasswordVisible: _isPasswordVisible,
                onPasswordVisibilityChanged: (value) {
                  setState(() => _isPasswordVisible = value);
                },
              ),
              LoginActions(
                rememberMe: _rememberMe,
                onRememberMeChanged: (value) {
                  setState(() => _rememberMe = value);
                },
                onLoginPressed: _handleLogin,
              ),
            ],
          ),
        ),
        if (_isSubmitting)
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black26,
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}
