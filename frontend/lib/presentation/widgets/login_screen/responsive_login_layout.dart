// frontend/lib/presentation/widgets/login_screen/responsive_login_layout.dart

import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/login_screen/web_login_layout.dart';
import 'package:frontend/presentation/widgets/login_screen/mobile_login_layout.dart';
import 'package:frontend/presentation/widgets/common/common_responsive_breakpoints.dart';

class ResponsiveLoginLayout extends StatelessWidget {
  const ResponsiveLoginLayout({super.key});

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
                    : 'mobile_layout'),
            child: CommonResponsiveBreakpoints.isWeb(constraints.maxWidth)
                ? const WebLoginLayout()
                : const MobileLoginLayout(),
          ),
        );
      },
    );
  }
}
