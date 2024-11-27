// frontend/lib/presentation/widgets/common/common_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/presentation/configuration/localization/app_texts.dart';

class CommonTextField extends StatelessWidget {
  final String labelText;
  final IconData? icon;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onPasswordToggle;
  final String? helperText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? initialValue;
  final AutovalidateMode? autovalidateMode;
  final String? prefixText;
  final String? suffixText;
  final Widget? suffix;
  final EdgeInsetsGeometry? contentPadding;

  const CommonTextField({
    super.key,
    required this.labelText,
    this.icon,
    this.focusNode,
    this.controller,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onPasswordToggle,
    this.helperText,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.onSaved,
    this.inputFormatters,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.readOnly = false,
    this.onTap,
    this.initialValue,
    this.autovalidateMode,
    this.prefixText,
    this.suffixText,
    this.suffix,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: isPassword && !isPasswordVisible,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLines: isPassword ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      onSaved: onSaved,
      inputFormatters: inputFormatters,
      onTap: onTap,
      autovalidateMode: autovalidateMode,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: enabled ? theme.textTheme.bodyLarge?.color : theme.disabledColor,
        fontSize: 16,
        height: 1.2,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        helperText: helperText ?? ' ',
        helperStyle: theme.textTheme.bodySmall?.copyWith(
          fontSize: 12,
          height: 1.2,
          color: Colors.transparent,
        ),
        helperMaxLines: 1,
        errorMaxLines: 1,
        prefixIcon: icon != null
            ? Icon(
                icon,
                color: enabled
                    ? focusNode != null && focusNode!.hasFocus
                        ? theme.colorScheme.primary
                        : theme.iconTheme.color
                    : theme.disabledColor,
              )
            : null,
        prefixText: prefixText,
        suffixText: suffixText,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: enabled
                      ? focusNode != null && focusNode!.hasFocus
                          ? theme.colorScheme.primary
                          : theme.iconTheme.color
                      : theme.disabledColor,
                ),
                onPressed: enabled ? onPasswordToggle : null,
                tooltip: isPasswordVisible
                    ? 'Ocultar contraseña'
                    : 'Mostrar contraseña',
              )
            : null,
        suffix: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: theme.disabledColor,
          ),
        ),
        filled: true,
        fillColor: enabled
            ? theme.colorScheme.surface
            : theme.disabledColor.withOpacity(0.1),
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
          height: 1.2,
          fontSize: 12,
        ),
        isDense: true,
      ),
    );
  }

  /// Factory constructor for an email field
  factory CommonTextField.email({
    Key? key,
    required FocusNode focusNode,
    TextEditingController? controller,
    ValueChanged<String>? onFieldSubmitted,
    FormFieldValidator<String>? validator,
    FormFieldSetter<String>? onSaved,
    bool enabled = true,
    TextInputAction? textInputAction,
  }) {
    return CommonTextField(
      key: key,
      labelText: AppTexts.emailPlaceholder,
      icon: Icons.email,
      focusNode: focusNode,
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction ?? TextInputAction.next,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator ?? _defaultEmailValidator,
      onSaved: onSaved,
      enabled: enabled,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(r'\s')),
        LengthLimitingTextInputFormatter(100),
      ],
    );
  }

  /// Factory constructor for a password field
  factory CommonTextField.password({
    Key? key,
    required FocusNode focusNode,
    required bool isPasswordVisible,
    required VoidCallback onPasswordToggle,
    TextEditingController? controller,
    ValueChanged<String>? onFieldSubmitted,
    FormFieldValidator<String>? validator,
    FormFieldSetter<String>? onSaved,
    bool enabled = true,
    String labelText = '',
    TextInputAction? textInputAction,
  }) {
    return CommonTextField(
      key: key,
      labelText:
          labelText.isNotEmpty ? labelText : AppTexts.passwordPlaceholder,
      icon: Icons.lock,
      focusNode: focusNode,
      controller: controller,
      isPassword: true,
      isPasswordVisible: isPasswordVisible,
      onPasswordToggle: onPasswordToggle,
      textInputAction: textInputAction ?? TextInputAction.done,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator ?? _defaultPasswordValidator,
      onSaved: onSaved,
      enabled: enabled,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
      ],
    );
  }

  /// Factory constructor for a name field
  factory CommonTextField.name({
    Key? key,
    required FocusNode focusNode,
    TextEditingController? controller,
    ValueChanged<String>? onFieldSubmitted,
    FormFieldValidator<String>? validator,
    FormFieldSetter<String>? onSaved,
    bool enabled = true,
    TextInputAction? textInputAction,
  }) {
    return CommonTextField(
      key: key,
      labelText: AppTexts.namePlaceholder,
      icon: Icons.person,
      focusNode: focusNode,
      controller: controller,
      keyboardType: TextInputType.name,
      textInputAction: textInputAction ?? TextInputAction.next,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator ?? _defaultNameValidator,
      onSaved: onSaved,
      enabled: enabled,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
      ],
    );
  }

  /// Default validators
  static String? _defaultEmailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppTexts.emailRequired;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return AppTexts.emailInvalid;
    }
    return null;
  }

  static String? _defaultPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppTexts.passwordRequired;
    }
    if (value.length < 6) {
      return AppTexts.passwordTooShort;
    }
    return null;
  }

  static String? _defaultNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppTexts.nameRequired;
    }
    return null;
  }
}
