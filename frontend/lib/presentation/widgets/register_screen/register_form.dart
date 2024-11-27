// lib/presentation/widgets/register_screen/register_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/widgets/register_screen/register_form_fields.dart';
import 'package:frontend/presentation/widgets/register_screen/register_actions.dart';
import 'package:frontend/presentation/providers/user_provider.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:frontend/presentation/widgets/common/common_snackbar.dart';
import 'package:go_router/go_router.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

  Future<void> _handleRegister() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      _showErrorMessage(AppTexts.formValidationError);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorMessage(AppTexts.passwordsDoNotMatch);
      return;
    }

    _showLoadingOverlay(true);

    try {
      final userProvider = context.read<UserProvider>();
      await userProvider.registerUser(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        if (userProvider.isAuthenticated) {
          _showSuccessMessage(AppTexts.registerSuccess);
          // Pequeño delay para que el usuario pueda ver el mensaje de éxito
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            context.go('/home');
          }
        } else {
          _showErrorMessage(AppTexts.registrationError);
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
              RegisterFormFields(
                nameController: _nameController,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                isPasswordVisible: _isPasswordVisible,
                isConfirmPasswordVisible: _isConfirmPasswordVisible,
                onPasswordVisibilityChanged: (value) {
                  setState(() => _isPasswordVisible = value);
                },
                onConfirmPasswordVisibilityChanged: (value) {
                  setState(() => _isConfirmPasswordVisible = value);
                },
              ),
              RegisterActions(
                onRegisterPressed: _handleRegister,
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
