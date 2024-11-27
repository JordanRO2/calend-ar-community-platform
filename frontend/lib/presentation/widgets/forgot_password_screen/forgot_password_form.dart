// lib/presentation/widgets/forgot_password_screen/forgot_password_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/widgets/forgot_password_screen/forgot_password_form_fields.dart';
import 'package:frontend/presentation/widgets/forgot_password_screen/forgot_password_actions.dart';
import 'package:frontend/presentation/providers/user_provider.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';
import 'package:frontend/presentation/widgets/common/common_snackbar.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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

  Future<void> _handleResetPassword() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      _showErrorMessage(AppTexts.loginFormError);
      return;
    }

    _showLoadingOverlay(true);

    try {
      final userProvider = context.read<UserProvider>();
      await userProvider.resetPassword(_emailController.text.trim());

      if (mounted) {
        _showSuccessMessage(AppTexts.resetPasswordEmailSent);
        // Pequeño delay para que el usuario pueda ver el mensaje de éxito
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.go('/login');
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
              ForgotPasswordFormFields(
                emailController: _emailController,
              ),
              ForgotPasswordActions(
                onResetPressed: _handleResetPassword,
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
