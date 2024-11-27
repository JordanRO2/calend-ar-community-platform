// lib/presentation/widgets/forgot_password_screen/responsive_forgot_password_layout.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/forgot_password_screen/web_forgot_password_layout.dart';
import 'package:frontend/presentation/widgets/forgot_password_screen/mobile_forgot_password_layout.dart';
import 'package:frontend/presentation/widgets/common/common_responsive_breakpoints.dart';

class ResponsiveForgotPasswordLayout extends StatelessWidget {
  const ResponsiveForgotPasswordLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(
            key: ValueKey(
              CommonResponsiveBreakpoints.isWeb(constraints.maxWidth)
                  ? 'web_layout'
                  : 'mobile_layout',
            ),
            child: CommonResponsiveBreakpoints.isWeb(constraints.maxWidth)
                ? const WebForgotPasswordLayout()
                : const MobileForgotPasswordLayout(),
          ),
        );
      },
    );
  }
}
