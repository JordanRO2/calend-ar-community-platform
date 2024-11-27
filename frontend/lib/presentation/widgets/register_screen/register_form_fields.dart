// lib/presentation/widgets/register_screen/register_form_fields.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/common/common_text_field.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';

class RegisterFormFields extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final ValueChanged<bool> onPasswordVisibilityChanged;
  final ValueChanged<bool> onConfirmPasswordVisibilityChanged;

  const RegisterFormFields({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isPasswordVisible,
    required this.isConfirmPasswordVisible,
    required this.onPasswordVisibilityChanged,
    required this.onConfirmPasswordVisibilityChanged,
  });

  @override
  State<RegisterFormFields> createState() => _RegisterFormFieldsState();
}

class _RegisterFormFieldsState extends State<RegisterFormFields> {
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        children: [
          CommonTextField.name(
            focusNode: _nameFocusNode,
            controller: widget.nameController,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_emailFocusNode);
            },
          ),
          const SizedBox(height: 16),
          CommonTextField.email(
            focusNode: _emailFocusNode,
            controller: widget.emailController,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFocusNode);
            },
          ),
          const SizedBox(height: 16),
          CommonTextField.password(
            focusNode: _passwordFocusNode,
            controller: widget.passwordController,
            isPasswordVisible: widget.isPasswordVisible,
            onPasswordToggle: () {
              widget.onPasswordVisibilityChanged(!widget.isPasswordVisible);
            },
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
            },
          ),
          const SizedBox(height: 16),
          CommonTextField.password(
            focusNode: _confirmPasswordFocusNode,
            controller: widget.confirmPasswordController,
            isPasswordVisible: widget.isConfirmPasswordVisible,
            onPasswordToggle: () {
              widget.onConfirmPasswordVisibilityChanged(
                  !widget.isConfirmPasswordVisible);
            },
            labelText: AppTexts.confirmPasswordPlaceholder,
            onFieldSubmitted: (_) {
              _confirmPasswordFocusNode.unfocus();
            },
          ),
        ],
      ),
    );
  }
}
