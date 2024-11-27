// frontend/lib/presentation/widgets/register_screen/responsive_register_layout.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/register_screen/web_register_layout.dart';
import 'package:frontend/presentation/widgets/register_screen/mobile_register_layout.dart';
import 'package:frontend/presentation/widgets/common/common_responsive_breakpoints.dart';

class ResponsiveRegisterLayout extends StatelessWidget {
  const ResponsiveRegisterLayout({super.key});

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
                ? const WebRegisterLayout()
                : const MobileRegisterLayout(),
          ),
        );
      },
    );
  }
}
