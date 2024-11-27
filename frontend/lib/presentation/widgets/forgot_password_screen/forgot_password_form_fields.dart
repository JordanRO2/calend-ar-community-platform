// lib/presentation/widgets/forgot_password_screen/forgot_password_form_fields.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/common/common_text_field.dart';

class ForgotPasswordFormFields extends StatefulWidget {
  final TextEditingController emailController;

  const ForgotPasswordFormFields({
    super.key,
    required this.emailController,
  });

  @override
  State<ForgotPasswordFormFields> createState() =>
      _ForgotPasswordFormFieldsState();
}

class _ForgotPasswordFormFieldsState extends State<ForgotPasswordFormFields> {
  final _emailFocusNode = FocusNode();

  @override
  void dispose() {
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        children: [
          CommonTextField.email(
            focusNode: _emailFocusNode,
            controller: widget.emailController,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              _emailFocusNode.unfocus();
            },
          ),
        ],
      ),
    );
  }
}
