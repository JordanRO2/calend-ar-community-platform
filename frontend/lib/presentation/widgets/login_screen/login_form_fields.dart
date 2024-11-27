// lib/presentation/widgets/login_screen/login_form_fields.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/common/common_text_field.dart';

class LoginFormFields extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final ValueChanged<bool> onPasswordVisibilityChanged;

  const LoginFormFields({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.onPasswordVisibilityChanged,
  });

  @override
  State<LoginFormFields> createState() => _LoginFormFieldsState();
}

class _LoginFormFieldsState extends State<LoginFormFields> {
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _setupFocusNodes();
  }

  void _setupFocusNodes() {
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CommonTextField.email(
            focusNode: _emailFocusNode,
            controller: widget.emailController,
            textInputAction: TextInputAction.next,
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
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              _passwordFocusNode.unfocus();
            },
          ),
        ],
      ),
    );
  }
}
